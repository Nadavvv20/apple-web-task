const request = require('supertest');

// We mock mongoose here so the test runner doesn't try to actually connect to a real MongoDB database 
// running locally or in CI, which would otherwise cause the test to timeout and fail.
jest.mock('mongoose', () => {
    return {
        connect: jest.fn().mockResolvedValue(true),
        model: jest.fn().mockReturnValue({
            findOne: jest.fn().mockResolvedValue({ name: 'apples', qty: 5 })
        }),
        Schema: jest.fn()
    };
});

// Require our server (this works because we added module.exports to server.js)
const server = require('./server');

describe('🍎 Web Server Test', () => {
    
// (No afterAll needed, Supertest closes the ephemeral server automatically)

    it('GET / should serve the HTML file', async () => {
        const response = await request(server).get('/');
        
        // Assertions: 
        // 1. We expect the response to be 200 OK
        // 2. We expect the content to have our apple heading
        expect(response.status).toBe(200);
        expect(response.text).toContain('Welcome to the apple storage');
    });

    it('GET /api/apples should return our mocked database count', async () => {
        const response = await request(server).get('/api/apples');
        
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('count', 5);
    });
});
