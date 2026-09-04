// CampusOS Backend REST API Server
// Zero dependencies: built using native Node.js 'http', 'fs', and 'path' modules

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'backend_data.json');

// Load in-memory store from backend_data.json
let store = {};
try {
  const raw = fs.readFileSync(DATA_FILE, 'utf8');
  store = JSON.parse(raw);
  console.log(`[Backend] Loaded data successfully with ${store.assignments?.length || 0} assignments, ${store.events?.length || 0} events.`);
} catch (err) {
  console.error('[Backend Error] Failed to read backend_data.json:', err);
  process.exit(1);
}

function saveStore() {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(store, null, 2), 'utf8');
  } catch (err) {
    console.error('[Backend Error] Failed to persist data:', err);
  }
}

// MIME types for static assets
const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // --- REST API ENDPOINTS ---
  if (pathname.startsWith('/api/')) {
    res.setHeader('Content-Type', 'application/json');

    // Helper to read request JSON body
    const parseBody = (cb) => {
      let body = '';
      req.on('data', chunk => body += chunk);
      req.on('end', () => {
        try {
          cb(body ? JSON.parse(body) : {});
        } catch (e) {
          res.writeHead(400);
          res.end(JSON.stringify({ error: 'Invalid JSON body' }));
        }
      });
    };

    // 1. Snapshot / Full Database
    if (pathname === '/api/data' && method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify(store, null, 2));
      return;
    }

    // 2. Assignments
    if (pathname === '/api/assignments') {
      if (method === 'GET') {
        const course = parsedUrl.searchParams.get('course');
        const status = parsedUrl.searchParams.get('status');
        let list = [...(store.assignments || [])];
        if (course) list = list.filter(a => a.course.toLowerCase().includes(course.toLowerCase()));
        if (status) list = list.filter(a => a.status.toLowerCase() === status.toLowerCase());
        res.writeHead(200);
        res.end(JSON.stringify({ count: list.length, assignments: list }));
        return;
      }

      if (method === 'POST') {
        parseBody(data => {
          const newAsg = {
            id: 'assign-' + Date.now(),
            status: data.status || 'Pending',
            points: Number(data.points) || 100,
            ...data
          };
          store.assignments.push(newAsg);
          saveStore();
          res.writeHead(201);
          res.end(JSON.stringify({ success: true, assignment: newAsg }));
        });
        return;
      }
    }

    // 3. Events
    if (pathname === '/api/events') {
      if (method === 'GET') {
        const category = parsedUrl.searchParams.get('category');
        const search = parsedUrl.searchParams.get('search');
        let list = [...(store.events || [])];
        if (category) list = list.filter(e => e.category.toLowerCase().includes(category.toLowerCase()));
        if (search) list = list.filter(e => e.name.toLowerCase().includes(search.toLowerCase()) || e.description?.toLowerCase().includes(search.toLowerCase()));
        res.writeHead(200);
        res.end(JSON.stringify({ count: list.length, events: list }));
        return;
      }
    }

    // Event Registration
    const eventRegMatch = pathname.match(/^\/api\/events\/([^\/]+)\/register$/);
    if (eventRegMatch && method === 'POST') {
      const eventId = eventRegMatch[1];
      const evt = store.events.find(e => e.id === eventId || e.name.toLowerCase() === eventId.toLowerCase());
      if (!evt) {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Event not found' }));
        return;
      }
      parseBody(data => {
        const attendee = data.name || store.user?.name || 'Anonymous Student';
        if (!evt.attendees) evt.attendees = [];
        if (evt.attendees.includes(attendee)) {
          res.writeHead(400);
          res.end(JSON.stringify({ success: false, error: 'Already registered' }));
          return;
        }
        if (evt.capacity && evt.registered_count >= evt.capacity) {
          res.writeHead(400);
          res.end(JSON.stringify({ success: false, error: 'Event at full capacity' }));
          return;
        }
        evt.attendees.push(attendee);
        evt.registered_count = (evt.registered_count || 0) + 1;
        evt.is_registered = true;
        saveStore();
        res.writeHead(200);
        res.end(JSON.stringify({ success: true, event: evt }));
      });
      return;
    }

    // 4. Schedules
    if (pathname === '/api/schedule' && method === 'GET') {
      const day = parsedUrl.searchParams.get('day');
      const course = parsedUrl.searchParams.get('course');
      let list = [...(store.schedule || [])];
      if (day) list = list.filter(s => s.day.toLowerCase() === day.toLowerCase());
      if (course) list = list.filter(s => s.course.toLowerCase().includes(course.toLowerCase()));
      res.writeHead(200);
      res.end(JSON.stringify({ count: list.length, schedule: list }));
      return;
    }

    // 5. Rooms & Booking
    if (pathname === '/api/rooms' && method === 'GET') {
      const minCap = parsedUrl.searchParams.get('min_capacity');
      let list = [...(store.rooms || [])];
      if (minCap) list = list.filter(r => r.capacity >= Number(minCap));
      res.writeHead(200);
      res.end(JSON.stringify({ count: list.length, rooms: list }));
      return;
    }

    const roomBookMatch = pathname.match(/^\/api\/rooms\/([^\/]+)\/book$/);
    if (roomBookMatch && method === 'POST') {
      const roomNum = decodeURIComponent(roomBookMatch[1]).toLowerCase();
      const room = store.rooms.find(r => r.room_number.toString().toLowerCase() === roomNum);
      if (!room) {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Room not found' }));
        return;
      }
      parseBody(booking => {
        const newBk = {
          id: 'bk_' + Date.now(),
          date: booking.date || '2026-09-04',
          startTime: booking.startTime,
          endTime: booking.endTime,
          bookedBy: booking.bookedBy || store.user?.name || 'Student',
          purpose: booking.purpose || 'Study & Collaboration'
        };
        if (!room.bookings) room.bookings = [];
        room.bookings.push(newBk);
        saveStore();
        res.writeHead(200);
        res.end(JSON.stringify({ success: true, booking: newBk, room }));
      });
      return;
    }

    // 6. Announcements
    if (pathname === '/api/announcements' && method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({ count: store.announcements.length, announcements: store.announcements }));
      return;
    }

    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Endpoint not found' }));
    return;
  }

  // --- STATIC FILE SERVING ---
  let filePath = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code === 'ENOENT') {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end(`Server Error: ${err.code}`);
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(PORT, () => {
  console.log(`[CampusOS Server] Running at http://localhost:${PORT}`);
  console.log(`[CampusOS API] REST endpoints available at http://localhost:${PORT}/api/`);
});
