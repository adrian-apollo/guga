extends Node

# Ruta donde se guardarán los logs (dentro de user:// que es la carpeta persistente del juego)
const RUTA_LOGS = "user://logs/"

var archivo_log: FileAccess
var ruta_archivo_actual: String = ""

func _ready() -> void:
 _inicializar_archivo_log()

func _inicializar_archivo_log() -> void:
 var dir = DirAccess.open("user://")
 
 # Si la carpeta 'logs' no existe, la creamos
 if not dir.dir_exists("logs"):
  dir.make_dir("logs")

 # Obtenemos la fecha y hora actual para el nombre del archivo
 var datetime = Time.get_datetime_dict_from_system()
 
 # Formato: YYYY-MM-DD_HH-MM-SS (Ej: 2026-03-30_14-30-15.log)
 var nombre_archivo = "%04d-%02d-%02d_%02d-%02d-%02d.log" % [
  datetime.year, datetime.month, datetime.day,
  datetime.hour, datetime.minute, datetime.second
 ]
 
 ruta_archivo_actual = RUTA_LOGS + nombre_archivo
 
 # Abrimos el archivo en modo escritura (WRITE)
 archivo_log = FileAccess.open(ruta_archivo_actual, FileAccess.WRITE)
 
 if archivo_log:
  print("Sistema de Log iniciado. Guardando en: ", ProjectSettings.globalize_path(ruta_archivo_actual))
  escribir("System", "Log file created successfully.")
 else:
  push_error("No se pudo crear el archivo de log en: " + ruta_archivo_actual)

# --- FUNCIÓN PRINCIPAL ---
func escribir(sender: String, mensaje: String) -> void:
 # 1. Obtenemos la hora actual para el registro interno (opcional pero muy útil)
 var time = Time.get_time_string_from_system()
 
 # 2. Formateamos el texto exactamente como lo pediste
 var linea_log = "%s >> %s\n" % [sender, mensaje]
 # (Si quieres que incluya la hora exacta de cada línea, usa esta línea en su lugar):
 # var linea_log = "[%s] %s >> %s\n" % [time, sender, mensaje]
 
 # 3. Imprimimos también en la consola de Godot para desarrollo
 print(linea_log.strip_edges())
 
 # 4. Guardamos en el archivo físico
 if archivo_log:
  archivo_log.store_string(linea_log)
  # Forzamos a que se escriba inmediatamente en disco (evita pérdida de datos si el juego crashea)
  archivo_log.flush()

# Nos aseguramos de cerrar el archivo correctamente cuando el juego se cierre
func _exit_tree() -> void:
 if archivo_log:
  archivo_log.close()
