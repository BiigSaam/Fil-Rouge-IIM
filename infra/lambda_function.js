const AWS = require('aws-sdk');
const crypto = require('crypto');

const dynamo = new AWS.DynamoDB.DocumentClient();
const TABLE_NAME = process.env.TABLE_NAME || 'TasksTable';

// Fonction pour générer un UUID simple avec crypto built-in
function generateUUID() {
  return crypto.randomUUID();
}

exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Lambda version: v2.0 - CORS fixed');
  
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Credentials': 'false'
  };

  // Gestion CORS
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: ''
    };
  }

  try {
    const { httpMethod, path, pathParameters, resource } = event;
    
    console.log('Path:', path);
    console.log('Resource:', resource);
    console.log('Method:', httpMethod);
    
    // GET /tasks - Récupérer toutes les tâches
    if (httpMethod === 'GET' && (path === '/tasks' || path === '/prod/tasks' || resource === '/tasks')) {
      const result = await dynamo.scan({
        TableName: TABLE_NAME
      }).promise();
      
      return {
        statusCode: 200,
        headers,
        body: JSON.stringify(result.Items || [])
      };
    }
    
    // POST /tasks - Créer une nouvelle tâche
    if (httpMethod === 'POST' && (path === '/tasks' || path === '/prod/tasks' || resource === '/tasks')) {
      const { title } = JSON.parse(event.body);
      
      if (!title) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ error: 'Title is required' })
        };
      }
      
      const newTask = {
        id: generateUUID(),
        title: title.trim(),
        createdAt: new Date().toISOString()
      };
      
      await dynamo.put({
        TableName: TABLE_NAME,
        Item: newTask
      }).promise();
      
      return {
        statusCode: 201,
        headers,
        body: JSON.stringify(newTask)
      };
    }
    
    // DELETE /tasks/{id} - Supprimer une tâche
    if (httpMethod === 'DELETE' && pathParameters && pathParameters.id && 
        (path.includes('/tasks/') || resource === '/tasks/{id}')) {
      await dynamo.delete({
        TableName: TABLE_NAME,
        Key: { id: pathParameters.id }
      }).promise();
      
      return {
        statusCode: 204,
        headers,
        body: ''
      };
    }
    
    // Route non trouvée
    return {
      statusCode: 404,
      headers,
      body: JSON.stringify({ error: 'Route not found' })
    };
    
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ 
        error: 'Internal server error',
        details: error.message 
      })
    };
  }
}; 