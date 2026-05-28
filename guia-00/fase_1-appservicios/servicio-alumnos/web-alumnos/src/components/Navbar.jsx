import { Link } from 'react-router-dom'
import { FaGraduationCap } from 'react-icons/fa'

function Navbar() {
  return (
    <nav className="bg-white shadow-lg border-b border-gray-200">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center py-4">
          <Link to="/" className="flex items-center space-x-2 text-primary-600 hover:text-primary-700 transition-colors">
            <FaGraduationCap className="w-8 h-8" />
            <span className="text-xl font-bold text-gray-800">Gestión de Alumnos</span>
          </Link>
          <div className="flex items-center space-x-4">
            <Link
              to="/"
              className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
            >
              Alumnos
            </Link>
            <Link
              to="/alumnos/nuevo"
              className="px-4 py-2 text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 rounded-lg transition-colors"
            >
              + Nuevo Alumno
            </Link>
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar
