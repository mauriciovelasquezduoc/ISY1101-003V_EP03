import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import alumnoService from '../services/alumnoService'

function AlumnoForm() {
  const navigate = useNavigate()
  const { id } = useParams()

  const [formData, setFormData] = useState({
    rut: '',
    nombre: '',
    apellido: '',
  })
  const [errors, setErrors] = useState({})
  const [loading, setLoading] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    if (id) {
      fetchAlumno()
    }
  }, [id])

  const fetchAlumno = async () => {
    try {
      const alumno = await alumnoService.getById(id)
      setFormData({
        rut: alumno.rut || '',
        nombre: alumno.nombre || '',
        apellido: alumno.apellido || '',
      })
    } catch (err) {
      console.error('Error fetching alumno:', err)
    }
  }

  const validate = () => {
    const newErrors = {}
    if (!formData.rut?.trim()) {
      newErrors.rut = 'El RUT es obligatorio'
    }
    if (!formData.nombre?.trim()) {
      newErrors.nombre = 'El nombre es obligatorio'
    }
    if (!formData.apellido?.trim()) {
      newErrors.apellido = 'El apellido es obligatorio'
    }
    return newErrors
  }

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: '' }))
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const validationErrors = validate()
    if (Object.keys(validationErrors).length > 0) {
      setErrors(validationErrors)
      return
    }

    setSubmitting(true)
    try {
      if (id) {
        await alumnoService.update(id, formData)
      } else {
        await alumnoService.create(formData)
      }
      navigate('/')
    } catch (err) {
      console.error('Error saving alumno:', err)
      alert('Error al guardar el alumno. Por favor, intente de nuevo.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800">
          {id ? 'Editar Alumno' : 'Nuevo Alumno'}
        </h1>
        <p className="text-gray-600 mt-1">
          {id ? 'Modifica los datos del alumno' : 'Registra un nuevo alumno en el sistema'}
        </p>
      </div>

      <div className="bg-white rounded-lg shadow-md p-8">
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="rut" className="block text-sm font-medium text-gray-700 mb-2">
                RUT *
              </label>
              <input
                type="text"
                id="rut"
                name="rut"
                value={formData.rut}
                onChange={handleChange}
                className={`w-full px-4 py-3 border ${errors.rut ? 'border-red-300' : 'border-gray-300'} rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all`}
                placeholder="12345678-9"
              />
              {errors.rut && <p className="mt-1 text-sm text-red-600">{errors.rut}</p>}
            </div>

            <div>
              <label htmlFor="nombre" className="block text-sm font-medium text-gray-700 mb-2">
                Nombre *
              </label>
              <input
                type="text"
                id="nombre"
                name="nombre"
                value={formData.nombre}
                onChange={handleChange}
                className={`w-full px-4 py-3 border ${errors.nombre ? 'border-red-300' : 'border-gray-300'} rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all`}
                placeholder="Juan"
              />
              {errors.nombre && <p className="mt-1 text-sm text-red-600">{errors.nombre}</p>}
            </div>

            <div>
              <label htmlFor="apellido" className="block text-sm font-medium text-gray-700 mb-2">
                Apellido *
              </label>
              <input
                type="text"
                id="apellido"
                name="apellido"
                value={formData.apellido}
                onChange={handleChange}
                className={`w-full px-4 py-3 border ${errors.apellido ? 'border-red-300' : 'border-gray-300'} rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all`}
                placeholder="Pérez"
              />
              {errors.apellido && <p className="mt-1 text-sm text-red-600">{errors.apellido}</p>}
            </div>
          </div>

          <div className="flex items-center justify-end space-x-4 pt-6 border-t border-gray-200">
            <button
              type="button"
              onClick={() => navigate('/')}
              className="px-6 py-3 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors font-medium"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="px-6 py-3 text-white bg-primary-600 hover:bg-primary-700 rounded-lg transition-colors font-medium flex items-center space-x-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {submitting ? (
                <>
                  <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                  <span>Guardando...</span>
                </>
              ) : (
                <span>{id ? 'Actualizar Alumno' : 'Crear Alumno'}</span>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

export default AlumnoForm
