// Dashboard.js
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import './Dashboard.css'; // Add your styles
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const [tasks, setTasks] = useState([]);
  const [selectedTask, setSelectedTask] = useState(null);
  const [historyData, setHistoryData] = useState(null);
  const [loadingTasks, setLoadingTasks] = useState(true);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [error, setError] = useState(null);

  const navigate = useNavigate();

  // Retrieve userId from localStorage
  const userId = localStorage.getItem('user_id');

  useEffect(() => {
    if (!userId) {
      // If no userId, redirect to login
      navigate('/');
    } else {
      // Fetch tasks
      const startTaskId = 1;
      const endTaskId = 50;
      fetchAllTasks(userId, startTaskId, endTaskId);
    }
  }, [userId, navigate]);

  const fetchAllTasks = async (userId, startTaskId, endTaskId) => {
    const tasksList = [];
    for (let taskId = startTaskId; taskId <= endTaskId; taskId++) {
      try {
        const response = await axios.post(
          `https://demo.lawie.app/ml/history/?user_id=${userId}&task_id=${taskId}`,
          null,
          {
            headers: {
              accept: 'application/json',
            },
          }
        );

        if (response.status === 200 && response.data) {
          tasksList.push({ task_id: taskId });
        }
      } catch (error) {
        // Task doesn't exist or error occurred; handle accordingly
        // You might want to log this or handle specific errors
      }
    }
    setTasks(tasksList);
    setLoadingTasks(false);
  };

  const fetchHistoryData = async (userId, taskId) => {
    setLoadingHistory(true);
    try {
      const response = await axios.post(
        `https://demo.lawie.app/ml/history/?user_id=${userId}&task_id=${taskId}`,
        null,
        {
          headers: {
            accept: 'application/json',
          },
        }
      );

      if (response.status === 200) {
        setHistoryData(response.data); // Set the history data
        setError(null);
      } else {
        setError('Failed to fetch history data');
      }
    } catch (error) {
      setError('Error fetching history');
    }
    setLoadingHistory(false);
  };

  const handleTaskClick = (task_id) => {
    setSelectedTask(task_id);
    fetchHistoryData(userId, task_id);
  };

  const handleLogout = () => {
    // Clear localStorage and redirect to login
    localStorage.removeItem('token');
    localStorage.removeItem('user_id');
    navigate('/');
  };

  return (
    <div className="dashboard-container">
      <div className="sidebar">
        <h2>Tasks</h2>
        {loadingTasks ? (
          <p>Loading tasks...</p>
        ) : tasks.length > 0 ? (
          <ul>
            {tasks.map((task) => (
              <li key={task.task_id} onClick={() => handleTaskClick(task.task_id)}>
                Task {task.task_id}
              </li>
            ))}
          </ul>
        ) : (
          <p>No tasks available</p>
        )}
        <button onClick={handleLogout} className="logout-btn">
          Logout
        </button>
      </div>
      <div className="main-window">
        {loadingHistory ? (
          <p>Loading history...</p>
        ) : error ? (
          <p>{error}</p>
        ) : selectedTask && historyData ? (
          <div className="history-details">
            <h2>History for Task {selectedTask}</h2>
            {/* Displaying data in tabular form */}
            <table>
              <tbody>
                <tr>
                  <th>Adapter ID</th>
                  <td>{historyData.adapter_id}</td>
                </tr>
                <tr>
                  <th>User ID</th>
                  <td>{historyData.user_id}</td>
                </tr>
                <tr>
                  <th>Task ID</th>
                  <td>{historyData.task_id}</td>
                </tr>
                <tr>
                  <th>Extracted Text</th>
                  <td>{historyData.extracted_text || 'No text extracted'}</td>
                </tr>
                <tr>
                  <th>QA Text</th>
                  <td>{historyData.qa_text || 'No QA text available'}</td>
                </tr>
              </tbody>
            </table>
          </div>
        ) : (
          <p>Select a task from the sidebar to view details</p>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
