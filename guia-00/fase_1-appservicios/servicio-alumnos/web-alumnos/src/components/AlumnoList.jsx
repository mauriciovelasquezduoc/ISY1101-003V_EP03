import { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { FaGraduationCap, FaSearch, FaEdit, FaTrash, FaPlus } from 'react-icons/fa'
import alumnoService from '../services/alumnoService'

function AlumnoList() {
  const [alumnos, setAlumnos] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchAlumnos()
  }, [])

  const fetchAlumnos = async () => {
    try {
      const data = await alumnoService.getAll()
      setAlumnos(data)
      setError(null)
    } catch (err) {
      setError('Error al cargar los alumnos. Por favor, intente de nuevo.')
      console.error('Error fetching alumnos:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id) => {
    if (window.confirm('¿Está seguro de eliminar este alumno?')) {
      try {
        await alumnoService.delete(id)
        setAlumnos(alumnos.filter((alumno) => alumno.id !== id))
      } catch (err) {
        setError('Error al eliminar el alumno.')
        console.error('Error deleting alumno:', err)
      }
    }
  }

  const filteredAlumnos = alumnos.filter(
    (alumno) =>
      alumno.nombre?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      alumno.apellido?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      alumno.rut?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row justify-between items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-800">Lista de Alumnos</h1>
          <p className="text-gray-600 mt-1">Gestione los alumnos registrados en el sistema</p>
        </div>
        <Link
          to="/alumnos/nuevo"
          className="flex items-center space-x-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors shadow-md hover:shadow-lg"
        >
          <FaPlus className="w-5 h-5" />
          <span>Nuevo Alumno</span>
        </Link>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
          {error}
        </div>
      )}

      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="mb-6">
          <div className="relative">
            <FaSearch className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Buscar por nombre, apellido o RUT..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all"
            />
          </div>
        </div>

        {filteredAlumnos.length === 0 ? (
          <div className="text-center py-12">
            <FaGraduationCap className="w-16 h-16 mx-auto text-gray-300 mb-4" />
            <h3 className="text-lg font-medium text-gray-900">No se encontraron alumnos</h3>
            <p className="text-gray-500 mt-1">Intenta con otro término de búsqueda</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50">
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">RUT</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nombre</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Apellido</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredAlumnos.map((alumno) => (
                  <tr key={alumno.id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{alumno.id}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{alumno.rut}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{alumno.nombre}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{alumno.apellido}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <div className="flex space-x-2">
                        <Link
                          to={`/alumnos/${alumno.id}`}
                          className="text-blue-600 hover:text-blue-900 p-1 rounded hover:bg-blue-50 transition-colors"
                          title="Ver detalles"
                        >
                          <FaGraduationCap className="w-5 h-5" />
                        </Link>
                        <Link
                          to={`/alumnos/${alumno.id}/editar`}
                          className="text-yellow-600 hover:text-yellow-900 p-1 rounded hover:bg-yellow-50 transition-colors"
                          title="Editar"
                        >
                          <FaEdit className="w-5 h-5" />
                        </Link>
                        <button
                          onClick={() => handleDelete(alumno.id)}
                          className="text-red-600 hover:text-red-900 p-1 rounded hover:bg-red-50 transition-colors"
                          title="Eliminar"
                        >
                          <FaTrash className="w-5 h-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}

export default AlumnoList
