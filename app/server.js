const http = require('http')
const fs = require('fs')
const path = require('path')
const port = 3000
const mongoose = require('mongoose')

// Connecting to MongoDB
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/fruitdb';
mongoose.connect(mongoUri)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => console.error('Could not connect to MongoDB', err));

// This create a variable that calls the model
const Fruit = require('./models/Fruit')

const server = http.createServer(async function (req, res) {
    // path for apples data
    if (req.url === '/api/apples') {
        try {
            // Search by the name apples
            const appleData = await Fruit.findOne({ name: 'apples' });

            res.writeHead(200, { 'Content-Type': 'application/json' });

            res.end(JSON.stringify({ count: appleData ? appleData.qty : 0 }));
        } catch (error) {
            console.error("Database error:", error);
            res.writeHead(500);
            res.end(JSON.stringify({ error: "Internal Server Error" }));
        }
        return
    }

    if (req.url === '/' || req.url === '/index.html') {
        fs.readFile('index.html', function (error, data) {
            if (error) {
                res.writeHead(404);
                res.write('Error: File Not Found');
            } else {
                res.writeHead(200, { 'Content-Type': 'text/html' });
                res.write(data);
            }
            res.end();
        });
    } else {
        res.writeHead(404);
        res.end('Route Not Found');
    }
})

if (require.main === module) {
    server.listen(port, function (error) {
        if (error) {
            console.log('Something went wrong')
        } else {
            console.log('Server is listening on port', port)
        }
    })
}

module.exports = server;