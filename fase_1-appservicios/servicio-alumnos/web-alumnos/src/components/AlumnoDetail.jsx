import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { FaGraduationCap, FaEdit, FaTrash, FaArrowLeft } from 'react-icons/fa'
import alumnoService from '../services/alumnoService'

function AlumnoDetail() {
  const navigate = useNavigate()
  const { id } = useParams()

  const [alumno, setAlumno] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchAlumno()
  }, [id])

  const fetchAlumno = async () => {
    try {
      const data = await alumnoService.getById(id)
      setAlumno(data)
      setError(null)
    } catch (err) {
      setError('Error al cargar los detalles del alumno.')
      console.error('Error fetching alumno:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async () => {
    if (window.confirm('¿Está seguro de eliminar este alumno?')) {
      try {
        await alumnoService.delete(id)
        navigate('/')
      } catch (err) {
        setError('Error al eliminar el alumno.')
        console.error('Error deleting alumno:', err)
      }
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg inline-block">
          {error}
        </div>
        <button
          onClick={() => navigate('/')}
          className="mt-4 text-primary-600 hover:text-primary-700"
        >
          Volver a la lista
        </button>
      </div>
    )
  }

  if (!alumno) {
    return (
      <div className="text-center py-12">
        <FaGraduationCap className="w-16 h-16 mx-auto text-gray-300 mb-4" />
        <h3 className="text-lg font-medium text-gray-900">Alumno no encontrado</h3>
        <button
          onClick={() => navigate('/')}
          className="mt-4 text-primary-600 hover:text-primary-700"
        >
          Volver a la lista
        </button>
      </div>
    )
  }

  return (
    <div className="max-w-2xl mx-auto">
      <button
        onClick={() => navigate('/')}
        className="flex items-center space-x-2 text-gray-600 hover:text-gray-900 mb-6 transition-colors"
      >
        <FaArrowLeft className="w-5 h-5" />
        <span>Volver a la lista</span>
      </button>

      <div className="bg-white rounded-lg shadow-md overflow-hidden">
        <div className="bg-primary-600 px-6 py-4">
          <h1 className="text-2xl font-bold text-white">Detalles del Alumno</h1>
        </div>

        <div className="px-6 py-8">
          <div className="space-y-6">
            <div className="flex items-center space-x-4 pb-6 border-b border-gray-200">
              <div className="w-20 h-20 bg-primary-100 rounded-full flex items-center justify-center">
                <FaGraduationCap className="w-10 h-10 text-primary-600" />
              </div>
              <div>
                <p className="text-sm text-gray-500">ID del registro</p>
                <p className="text-lg font-semibold text-gray-900">{alumno.id}</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <p className="text-sm font-medium text-gray-500 mb-1">RUT</p>
                <p className="text-lg font-semibold text-gray-900 bg-gray-50 px-4 py-2 rounded-lg">
                  {alumno.rut}
                </p>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-500 mb-1">Nombre</p>
                <p className="text-lg font-semibold text-gray-900 bg-gray-50 px-4 py-2 rounded-lg">
                  {alumno.nombre}
                </p>
              </div>

              <div>
                <p className="text-sm font-medium text-gray-500 mb-1">Apellido</p>
                <p className="text-lg font-semibold text-gray-900 bg-gray-50 px-4 py-2 rounded-lg">
                  {alumno.apellido}
                </p>
              </div>
            </div>

            <div className="pt-6 border-t border-gray-200 flex items-center justify-end space-x-4">
              <button
                onClick={() => handleDelete()}
                className="flex items-center space-x-2 px-6 py-3 text-red-600 bg-red-50 hover:bg-red-100 rounded-lg transition-colors font-medium"
              >
                <FaTrash className="w-5 h-5" />
                <span>Eliminar</span>
              </button>
              <button
                onClick={() => navigate(`/alumnos/${alumno.id}/editar`)}
                className="flex items-center space-x-2 px-6 py-3 text-white bg-primary-600 hover:bg-primary-700 rounded-lg transition-colors font-medium"
              >
                <FaEdit className="w-5 h-5" />
                <span>Editar</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default AlumnoDetail
