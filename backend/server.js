const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const db = require('./db');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);
    return callback(null, true);
  },
  credentials: true,
}));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.use(session({
    secret: process.env.SESSION_SECRET || 'pathpal-secret',
    resave: true,
    saveUninitialized: true,
    cookie: {
        secure: true,
        httpOnly: true,
        maxAge: 24 * 60 * 60 * 1000,
        sameSite: 'none'
    }
}));

const isAuthenticated = (req, res, next) => {
    if (req.session.user) {
        next();
    } else {
        if (req.path.startsWith('/api/')) {
            res.status(401).json({ success: false, message: 'Authentication required' });
        } else {
            res.redirect('/');
        }
    }
};

const isAdmin = (req, res, next) => {
    if (req.session.user && req.session.user.user_type === 'admin') {
        next();
    } else {
        if (req.path.startsWith('/api/')) {
            res.status(403).json({ success: false, message: 'Admin access required' });
        } else {
            res.redirect('/');
        }
    }
};

app.use('/api/auth', require('./routes/auth'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/user', require('./routes/user'));
app.use('/api/devices', require('./routes/devices'));

app.get('/auth/register', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/auth/register.html'));
});

app.get('/user/dashboard', isAuthenticated, (req, res) => {
    res.sendFile(path.join(__dirname, '../public/user/dashboard.html'));
});

app.get('/admin/dashboard', isAdmin, (req, res) => {
    res.sendFile(path.join(__dirname, '../public/admin/dashboard.html'));
});

app.get('/', (req, res) => {
    res.json({ message: 'API is running!' });
});

app.use((err, req, res, next) => {
    console.error('Error details:', {
        message: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method,
        body: req.body,
        query: req.query,
        params: req.params
    });
    
    if (process.env.NODE_ENV !== 'production') {
        res.status(500).json({
            success: false,
            message: 'Internal Server Error',
            error: err.message,
            stack: err.stack
        });
    } else {
        res.status(500).json({
            success: false,
            message: 'Internal Server Error'
        });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
}).on('error', (err) => {
    console.error('Server failed to start:', err);
    process.exit(1);
});
