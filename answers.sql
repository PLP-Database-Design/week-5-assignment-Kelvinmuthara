require('dotenv').config()
const express = require('express')
const mysql = require('mysql2')
const app = express()

// Database connection configuration
const db = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
})

// Test database connection
db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err)
        return
    }
    console.log('Successfully connected to the database!')
})

// Middleware to parse JSON bodies
app.use(express.json())

// 1. GET endpoint to retrieve all patients
app.get('/api/patients', (req, res) => {
    const query = `
        SELECT patient_id, first_name, last_name, date_of_birth 
        FROM patients
    `
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error executing query:', err)
            res.status(500).json({ error: 'Internal server error' })
            return
        }
        res.json(results)
    })
})

// 2. GET endpoint to retrieve all providers
app.get('/api/providers', (req, res) => {
    const query = `
        SELECT first_name, last_name, provider_speciality 
        FROM providers
    `
    db.query(query, (err, results) => {
        if (err) {
            console.error('Error executing query:', err)
            res.status(500).json({ error: 'Internal server error' })
            return
        }
        res.json(results)
    })
})

// 3. GET endpoint to filter patients by first name
app.get('/api/patients/search', (req, res) => {
    const firstName = req.query.firstName
    
    if (!firstName) {
        res.status(400).json({ error: 'First name parameter is required' })
        return
    }

    const query = `
        SELECT patient_id, first_name, last_name, date_of_birth 
        FROM patients 
        WHERE first_name LIKE ?
    `
    db.query(query, [`${firstName}%`], (err, results) => {
        if (err) {
            console.error('Error executing query:', err)
            res.status(500).json({ error: 'Internal server error' })
            return
        }
        res.json(results)
    })
})

// 4. GET endpoint to retrieve providers by specialty
app.get('/api/providers/specialty/:specialty', (req, res) => {
    const specialty = req.params.specialty

    const query = `
        SELECT first_name, last_name, provider_speciality 
        FROM providers 
        WHERE provider_speciality = ?
    `
    db.query(query, [specialty], (err, results) => {
        if (err) {
            console.error('Error executing query:', err)
            res.status(500).json({ error: 'Internal server error' })
            return
        }
        res.json(results)
    })
})

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack)
    res.status(500).json({ error: 'Something broke!' })
})

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' })
})

// Listen to the server
const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`)
})
