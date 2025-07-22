import { useEffect, useState } from 'react';

interface Task {
  id: number;
  title: string;
}

function App() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [newTask, setNewTask] = useState('');

  const fetchTasks = async () => {
    const res = await fetch('http://backend:3001/api/tasks');
    const data = await res.json();
    setTasks(data);
  };

  const addTask = async () => {
    if (!newTask.trim()) return;
    const res = await fetch('http://backend:3001/api/tasks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title: newTask }),
    });
    const data = await res.json();
    setTasks(prev => [...prev, data]);
    setNewTask('');
  };

  const deleteTask = async (id: number) => {
    await fetch(`http://backend:3001/api/tasks/${id}`, {
      method: 'DELETE',
    });
    setTasks(prev => prev.filter(t => t.id !== id));
  };

  useEffect(() => {
    fetchTasks();
  }, []);

  return (
    <div style={{ padding: '2rem' }}>
      <h1>Todo List</h1>
      <input
        type="text"
        placeholder="Nouvelle tâche"
        value={newTask}
        onChange={(e) => setNewTask(e.target.value)}
      />
      <button onClick={addTask}>Ajouter</button>
      <ul>
        {tasks.map((task) => (
          <li key={task.id}>
            {task.title}{' '}
            <button onClick={() => deleteTask(task.id)}>Supprimer</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
