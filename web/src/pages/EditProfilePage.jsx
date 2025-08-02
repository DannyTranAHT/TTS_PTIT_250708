// src/pages/LandingPage.jsx
import { Link } from 'react-router-dom';
import EditProfile from '../components/forms/EditProfile';
import Layout from '../components/layout/Layout';

export default function EditProfilePage() {
  return (
    <Layout>
      <EditProfile />
    </Layout>
  );
}
