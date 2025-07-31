import { useEffect, useState } from 'react';

interface Task {
  id: string;
  title: string;
  createdAt?: string;
}

function App() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [newTask, setNewTask] = useState('');
  const [loading, setLoading] = useState(false);
  
  const fetchTasks = async () => {
    try {
      setLoading(true);
      const res = await fetch(`https://rpcix8ja83.execute-api.eu-west-1.amazonaws.com/prod/tasks`);
      if (!res.ok) throw new Error('Erreur lors du chargement des tâches');
      const data = await res.json();
      setTasks(data);
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors du chargement des tâches');
    } finally {
      setLoading(false);
    }
  };

  const addTask = async () => {
    if (!newTask.trim()) return;
    
    try {
      setLoading(true);
      const res = await fetch(`https://rpcix8ja83.execute-api.eu-west-1.amazonaws.com/prod/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: newTask }),
      });
      
      if (!res.ok) throw new Error('Erreur lors de la création de la tâche');
      
      const data = await res.json();
      setTasks(prev => [...prev, data]);
      setNewTask('');
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la création de la tâche');
    } finally {
      setLoading(false);
    }
  };

  const deleteTask = async (id: string) => {
    try {
      setLoading(true);
      const res = await fetch(`https://rpcix8ja83.execute-api.eu-west-1.amazonaws.com/prod/tasks/${id}`, {
        method: 'DELETE',
      });
      
      if (!res.ok) throw new Error('Erreur lors de la suppression');
      
      setTasks(prev => prev.filter(t => t.id !== id));
    } catch (error) {
      console.error('Erreur:', error);
      alert('Erreur lors de la suppression de la tâche');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  return (
    <div style={{ padding: '2rem', maxWidth: '600px', margin: '0 auto' }}>
      <h1>📝 Todo List (Serverless)</h1>
      
      <div style={{ marginBottom: '1rem' }}>
        <input
          type="text"
          placeholder="Nouvelle tâche"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTask()}
          style={{ padding: '8px', marginRight: '8px', width: '300px' }}
          disabled={loading}
        />
        <button 
          onClick={addTask}
          disabled={loading || !newTask.trim()}
          style={{ padding: '8px 16px' }}
        >
          {loading ? '⏳' : 'Ajouter'}
        </button>
      </div>

      {loading && <p>Chargement...</p>}
      
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {tasks.map((task) => (
          <li 
            key={task.id}
            style={{ 
              display: 'flex', 
              justifyContent: 'space-between',
              alignItems: 'center',
              padding: '8px',
              margin: '4px 0',
              border: '1px solid #ddd',
              borderRadius: '4px'
            }}
          >
            <span>{task.title}</span>
            <button 
              onClick={() => deleteTask(task.id)}
              style={{ 
                padding: '4px 8px',
                backgroundColor: '#ff4444',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer'
              }}
              disabled={loading}
            >
              🗑️ Supprimer
            </button>
          </li>
        ))}
      </ul>
      
      {tasks.length === 0 && !loading && (
        <p style={{ textAlign: 'center', color: '#666' }}>
          Aucune tâche. Ajoutez-en une ! 🎯
        </p>
      )}
    </div>
  );
}

export default App;
