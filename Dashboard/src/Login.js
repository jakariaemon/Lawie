import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './Login.css'; // Import the CSS file for styling

const Login = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();

    const data = `grant_type=password&username=${encodeURIComponent(
      email
    )}&password=${encodeURIComponent(
      password
    )}&scope=&client_id=string&client_secret=string`;

    try {
      const response = await axios.post('https://demo.lawie.app/login', data, {
        headers: {
          accept: 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      });

      if (response.status === 200) {
        // Handle success, e.g., store token in localStorage or context
        const token = response.data.access_token;
        localStorage.setItem('token', token);

        // Store user_id in localStorage
        const userId = response.data.user.id; // Adjust based on your response structure
        localStorage.setItem('user_id', userId);

        // Redirect to dashboard or another page
        navigate('/dashboard');
      } else {
        setError('Login failed. Please check your credentials.');
      }
    } catch (error) {
      console.error('Login error:', error);
      setError('Error logging in. Please try again.');
    }
  };
  return (
    <div className="login-container">
      <div className="login-box">
        <img src="/images/logo.png" alt="Logo" className="logo" />
        <img src="/images/slogan.gif" alt="Slogan" className="slogan" />
        <form onSubmit={handleLogin} className="login-form">
          <div className="input-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your email"
              required
            />
          </div>
          <div className="input-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
            />
          </div>
          {error && <p className="error">{error}</p>}
          <button type="submit" className="login-btn">Login</button>
        </form>
      </div>
    </div>
  );
};

export default Login;
