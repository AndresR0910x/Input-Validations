from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import psycopg2
from psycopg2.extras import RealDictCursor
from passlib.context import CryptContext

# Configuración de la aplicación FastAPI
app = FastAPI()

# Habilitar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuración para hashear contraseñas
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Modelo Pydantic para validar los datos de entrada
class Usuario(BaseModel):
    nombre: str
    apellido: str
    cedula: str
    telefono: str
    fecha: str
    genero: str
    correo: str
    contrasena: str

# Conexión a PostgreSQL
def get_db_connection():
    try:
        conn = psycopg2.connect(
            dbname="validation_form",
            user="postgres",
            password="",  # Asegúrate de que la contraseña sea correcta
            host="localhost",
            cursor_factory=RealDictCursor
        )
        return conn
    except Exception as e:
        print(f"Error al conectar a la base de datos: {e}")
        raise HTTPException(status_code=500, detail="Error de conexión a la base de datos")

# Ruta para registrar un usuario
@app.post("/registrar")
async def registrar_usuario(usuario: Usuario):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Hashear la contraseña antes de guardarla
        hashed_password = pwd_context.hash(usuario.contrasena)

        # Insertar datos en la base de datos
        query = """
            INSERT INTO usuarios (nombre, apellido, cedula, telefono, fecha, genero, correo, contrasena)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING *;
        """
        cursor.execute(query, (
            usuario.nombre,
            usuario.apellido,
            usuario.cedula,
            usuario.telefono,
            usuario.fecha,
            usuario.genero,
            usuario.correo,
            hashed_password
        ))
        nuevo_usuario = cursor.fetchone()
        conn.commit()
        return nuevo_usuario
    except psycopg2.Error as e:
        conn.rollback()
        print(f"Error en la consulta SQL: {e}")
        raise HTTPException(status_code=500, detail=f"Error en la base de datos: {e}")
    except Exception as e:
        conn.rollback()
        print(f"Error inesperado: {e}")
        raise HTTPException(status_code=500, detail=f"Error inesperado: {e}")
    finally:
        cursor.close()
        conn.close()

# Iniciar el servidor
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8000)