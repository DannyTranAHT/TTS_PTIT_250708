import { Navigate } from "react-router-dom";

export default function ManagerRoute({ children }) {
  const user = JSON.parse(localStorage.getItem("user"));
  if (!user || (user.role !== "Admin" && user.role !== "Project Manager")) {
    return <Navigate to="/dashboard" replace />;
  }
  return children;
}