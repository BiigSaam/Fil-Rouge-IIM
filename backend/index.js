const express = require('express');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const AWS = require('aws-sdk');

const app = express();
const PORT = 3001;
const USE_DYNAMODB = false; // ← Mets à true quand tu connectes la vraie DB
const TABLE_NAME = 'TasksTable';
const AWS_REGION = 'eu-west-3';

app.use(cors());
app.use(express.json());

let tasks = [];

let dynamo;
if (USE_DYNAMODB) {
  AWS.config.update({ region: AWS_REGION });
  dynamo = new AWS.DynamoDB.DocumentClient();
}

// GET /api/tasks
app.get('/api/tasks', async (req, res) => {
  if (USE_DYNAMODB) {
    try {
      const data = await dynamo.scan({ TableName: TABLE_NAME }).promise();
      res.json(data.Items);
    } catch (err) {
      console.error('DynamoDB error:', err);
      res.status(500).json({ error: 'Erreur DynamoDB' });
    }
  } else {
    res.json(tasks);
  }
});

// POST /api/tasks
app.post('/api/tasks', async (req, res) => {
  const { title } = req.body;
  const newTask = { id: uuidv4(), title };

  if (USE_DYNAMODB) {
    try {
      await dynamo.put({
        TableName: TABLE_NAME,
        Item: newTask
      }).promise();
      res.status(201).json(newTask);
    } catch (err) {
      console.error('DynamoDB error:', err);
      res.status(500).json({ error: 'Erreur DynamoDB' });
    }
  } else {
    tasks.push(newTask);
    res.status(201).json(newTask);
  }
});

// DELETE /api/tasks/:id
app.delete('/api/tasks/:id', async (req, res) => {
  const { id } = req.params;

  if (USE_DYNAMODB) {
    try {
      await dynamo.delete({
        TableName: TABLE_NAME,
        Key: { id }
      }).promise();
      res.status(204).end();
    } catch (err) {
      console.error('DynamoDB error:', err);
      res.status(500).json({ error: 'Erreur DynamoDB' });
    }
  } else {
    tasks = tasks.filter(task => task.id !== id);
    res.status(204).end();
  }
});

app.listen(PORT, () => {
  console.log(`API running on port ${PORT} (DynamoDB enabled: ${USE_DYNAMODB})`);
});
