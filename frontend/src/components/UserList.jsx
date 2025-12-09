const UserList = ({ users, loading, onEdit, onDelete }) => {
    if (loading) {
        return (
            <div className="loading">
                <div className="spinner"></div>
            </div>
        );
    }

    if (users.length === 0) {
        return (
            <div className="empty-state">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                <h3>No users yet</h3>
                <p>Add your first user using the form above</p>
            </div>
        );
    }

    return (
        <div className="user-list">
            {users.map((user) => (
                <div key={user.id} className="user-item fade-in">
                    <div className="user-info">
                        <h3>{user.name}</h3>
                        <p>{user.email}</p>
                    </div>
                    <div className="user-actions">
                        <button
                            className="btn btn-secondary btn-sm"
                            onClick={() => onEdit(user)}
                        >
                            Edit
                        </button>
                        <button
                            className="btn btn-danger btn-sm"
                            onClick={() => onDelete(user.id)}
                        >
                            Delete
                        </button>
                    </div>
                </div>
            ))}
        </div>
    );
};

export default UserList;
