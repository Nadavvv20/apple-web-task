const mongoose = require('mongoose')

const fruitSchema = new mongoose.Schema({
    name: String,
    qty: Number,
    rating: Number
})

module.exports = mongoose.model('Fruit', fruitSchema, 'fruits')