import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import AlumnoList from './components/AlumnoList'
import AlumnoForm from './components/AlumnoForm'
import AlumnoDetail from './components/AlumnoDetail'
import Navbar from './components/Navbar'

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-50">
        <Navbar />
        <main className="container mx-auto px-4 py-8">
          <Routes>
            <Route path="/" element={<AlumnoList />} />
            <Route path="/alumnos/nuevo" element={<AlumnoForm />} />
            <Route path="/alumnos/:id/editar" element={<AlumnoForm />} />
            <Route path="/alumnos/:id" element={<AlumnoDetail />} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

export default App
