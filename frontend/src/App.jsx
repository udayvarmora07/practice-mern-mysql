import { useState, useEffect } from 'react';
import UserList from './components/UserList';

const API_URL = '/api/users';

function App() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(null);
    const [formData, setFormData] = useState({ name: '', email: '' });
    const [editingId, setEditingId] = useState(null);
    const [submitting, setSubmitting] = useState(false);

    // Fetch users
    const fetchUsers = async () => {
        try {
            setLoading(true);
            const response = await fetch(API_URL);
            const data = await response.json();
            if (data.success) {
                setUsers(data.data);
            } else {
                setError(data.message);
            }
        } catch (err) {
            setError('Failed to connect to server');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUsers();
    }, []);

    // Clear messages after 3 seconds
    useEffect(() => {
        if (success || error) {
            const timer = setTimeout(() => {
                setSuccess(null);
                setError(null);
            }, 3000);
            return () => clearTimeout(timer);
        }
    }, [success, error]);

    // Handle form submit
    const handleSubmit = async (e) => {
        e.preventDefault();
        setSubmitting(true);
        setError(null);

        try {
            const url = editingId ? `${API_URL}/${editingId}` : API_URL;
            const method = editingId ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            const data = await response.json();

            if (data.success) {
                setSuccess(editingId ? 'User updated successfully!' : 'User created successfully!');
                setFormData({ name: '', email: '' });
                setEditingId(null);
                fetchUsers();
            } else {
                setError(data.message);
            }
        } catch (err) {
            setError('Failed to save user');
        } finally {
            setSubmitting(false);
        }
    };

    // Handle edit
    const handleEdit = (user) => {
        setFormData({ name: user.name, email: user.email });
        setEditingId(user.id);
        setError(null);
        setSuccess(null);
    };

    // Handle delete
    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this user?')) return;

        try {
            const response = await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
            const data = await response.json();

            if (data.success) {
                setSuccess('User deleted successfully!');
                fetchUsers();
            } else {
                setError(data.message);
            }
        } catch (err) {
            setError('Failed to delete user');
        }
    };

    // Handle cancel edit
    const handleCancel = () => {
        setFormData({ name: '', email: '' });
        setEditingId(null);
        setError(null);
    };

    return (
        <div className="app">
            <div className="container">
                <header>
                    <h1>User Management</h1>
                    <p>MERN Stack with MySQL Database</p>
                </header>

                {/* Notifications */}
                {success && <div className="alert alert-success fade-in">{success}</div>}
                {error && <div className="alert alert-error fade-in">{error}</div>}

                {/* Add/Edit User Form */}
                <div className="card">
                    <h2 className="card-title">{editingId ? 'Edit User' : 'Add New User'}</h2>
                    <form onSubmit={handleSubmit}>
                        <div className="form-row">
                            <div className="form-group">
                                <label htmlFor="name">Name</label>
                                <input
                                    type="text"
                                    id="name"
                                    placeholder="Enter name"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label htmlFor="email">Email</label>
                                <input
                                    type="email"
                                    id="email"
                                    placeholder="Enter email"
                                    value={formData.email}
                                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                    required
                                />
                            </div>
                        </div>
                        <div style={{ display: 'flex', gap: '0.75rem', marginTop: '0.5rem' }}>
                            <button type="submit" className="btn btn-primary" disabled={submitting}>
                                {submitting ? 'Saving...' : editingId ? 'Update User' : 'Add User'}
                            </button>
                            {editingId && (
                                <button type="button" className="btn btn-secondary" onClick={handleCancel}>
                                    Cancel
                                </button>
                            )}
                        </div>
                    </form>
                </div>

                {/* User List */}
                <div className="card">
                    <h2 className="card-title">Users</h2>
                    <UserList
                        users={users}
                        loading={loading}
                        onEdit={handleEdit}
                        onDelete={handleDelete}
                    />
                </div>

                <footer>
                    Built with React, Node.js, Express & MySQL
                </footer>
            </div>
        </div>
    );
}

export default App;
