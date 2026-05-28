import axios from 'axios'

const API_URL = '/api/alumnos'

const alumnoService = {
  getAll: async () => {
    const response = await axios.get(API_URL)
    return response.data
  },

  getById: async (id) => {
    const response = await axios.get(`${API_URL}/${id}`)
    return response.data
  },

  getByRut: async (rut) => {
    const response = await axios.get(`${API_URL}/rut/${rut}`)
    return response.data
  },

  create: async (alumno) => {
    const response = await axios.post(API_URL, alumno)
    return response.data
  },

  update: async (id, alumno) => {
    const response = await axios.put(`${API_URL}/${id}`, alumno)
    return response.data
  },

  delete: async (id) => {
    await axios.delete(`${API_URL}/${id}`)
  },
}

export default alumnoService
