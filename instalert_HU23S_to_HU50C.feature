# InstAlert Acceptance Tests: HU-23S to HU-50C
# Idioma: es
# Nota: HU-23S a HU-33C se basan en el documento compartido.
# HU-34+ son inferidas para mantener coherencia funcional con EP-02M, EP-03P, EP-04C y EP-05S.

Feature: HU-23S - Políticas de privacidad claras
  Como ciudadano, quiero ver un resumen claro de cómo se usan mis datos,
  para decidir si acepto usar la aplicación.

  Scenario Outline: Resumen visible en registro
    Given que el usuario se registra por primera vez
    When el usuario avanza al paso "<paso>"
    Then el sistema muestra un resumen "<visibilidad>" de políticas de privacidad
    Examples:
      | paso                                   | visibilidad    |
      | aceptación de términos y políticas     | claro y breve  |
      | consentimiento de tratamiento de datos | claro y breve  |

  Scenario Outline: Restricción de acceso si no acepta
    Given que el usuario no acepta las políticas
    When el usuario intenta "<accion>"
    Then el sistema no le permite finalizar su registro
    And muestra el mensaje "<mensaje>"
    Examples:
      | accion                | mensaje                                  |
      | continuar el registro | Debe aceptar las políticas para continuar|
      | usar la aplicación    | Debe aceptar las políticas para continuar|

  Scenario Outline: Acceso posterior a las políticas
    Given que el usuario ya está registrado
    When el usuario abre "<ruta>"
    Then el sistema muestra los detalles de las políticas en cualquier momento
    Examples:
      | ruta                                      |
      | Configuración > Políticas de privacidad   |
      | Perfil > Seguridad > Políticas de datos   |

  Scenario Outline: Notificación de cambios en políticas
    Given que las políticas han cambiado
    When el usuario recibe el aviso de actualización al abrir la aplicación
    Then el sistema exige aceptar nuevamente para continuar usando la app
    And registra "<evento>" en el log de seguridad
    Examples:
      | evento                  |
      | reaceptación de políticas|


Feature: HU-24S - Notificación de intentos de acceso sospechosos
  Como usuario, quiero recibir alertas cuando alguien intente acceder a mi cuenta,
  para proteger mi información a tiempo.

  Scenario Outline: Notificación por inicio desde dispositivo no registrado
    Given que la detección de nuevos dispositivos está habilitada
    And el canal de notificación "<canal>" está verificado
    When se intenta iniciar sesión desde un dispositivo no registrado "<origen>"
    Then la aplicación envía una notificación con "<datos>"
    Examples:
      | canal | origen     | datos                                   |
      | push  | web        | ubicación aproximada, dispositivo y hora|
      | email | móvil      | ubicación aproximada, dispositivo y hora|

  Scenario Outline: Bloqueo temporal por intentos fallidos
    Given que la cuenta tiene el umbral de "<umbral>" intentos fallidos
    When se supera el umbral de intentos fallidos consecutivos
    Then la aplicación bloquea temporalmente la cuenta por "<tiempo>"
    And envía una alerta al usuario
    Examples:
      | umbral | tiempo |
      | 5      | 15m    |
      | 10     | 30m    |

  Scenario Outline: Historial de alertas de seguridad
    Given que el usuario está autenticado
    And existen eventos de seguridad registrados
    When el usuario navega a "<ruta>"
    Then la aplicación muestra un historial con fecha, hora, origen y tipo de evento
    Examples:
      | ruta                                           |
      | Configuración > Seguridad > Intentos sospechosos|

  Scenario Outline: Confirmación de actividad
    Given que el sistema envió una alerta con enlace de verificación válido
    And la sesión del usuario está activa
    When el usuario selecciona "<confirmacion>"
    Then la aplicación registra la confirmación y actualiza el estado del evento
    Examples:
      | confirmacion |
      | Fui yo       |
      | No fui yo    |


Feature: HU-25S - Cierre de sesión automático
  Como usuario, quiero que la app cierre sesión tras un tiempo de inactividad,
  para evitar que otros usen mi cuenta sin permiso.

  Scenario Outline: Cierre tras inactividad
    Given que el usuario tiene una sesión activa
    When el usuario permanece inactivo durante "<minutos>" minutos
    Then la aplicación cierra la sesión automáticamente
    Examples:
      | minutos |
      | 10      |
      | 15      |

  Scenario Outline: Solicitud de nuevo login
    Given que la sesión del usuario caducó por inactividad
    When el usuario vuelve a abrir la app
    Then la aplicación exige iniciar sesión nuevamente con "<metodo>"
    Examples:
      | metodo   |
      | contraseña y 2FA |
      | contraseña       |

  Scenario Outline: Configuración del tiempo de inactividad
    Given que el usuario desea personalizar el tiempo de inactividad antes del cierre
    When el usuario abre "<ruta>" y ajusta el temporizador a "<minutos>" minutos
    Then la aplicación guarda la nueva configuración de tiempo
    Examples:
      | ruta                               | minutos |
      | Ajustes > Seguridad > Sesión       | 10      |
      | Ajustes > Seguridad > Sesión       | 20      |

  Scenario Outline: Aviso de cierre próximo
    Given que la sesión está por caducar y la aplicación está en primer plano
    When falta "<minutos>" minuto para el cierre
    Then el sistema muestra un aviso al usuario indicando el próximo cierre
    Examples:
      | minutos |
      | 1       |


Feature: HU-26S - Acceso con doble autenticación
  Como usuario, quiero activar doble autenticación,
  para reforzar la seguridad de mi cuenta.

  Scenario Outline: Activación de 2FA
    Given que el usuario accede a Configuración > Seguridad > Doble autenticación
    When habilita 2FA con "<mecanismo>"
    Then el sistema asocia el segundo factor y muestra estado activo
    Examples:
      | mecanismo |
      | TOTP      |
      | SMS       |

  Scenario Outline: Verificación de 2FA al iniciar sesión
    Given que la cuenta tiene 2FA habilitado
    When el usuario inicia sesión con credenciales válidas
    Then el sistema solicita el segundo factor "<mecanismo>" antes de conceder acceso
    Examples:
      | mecanismo |
      | TOTP      |
      | SMS       |

  Scenario Outline: Recuperación de 2FA
    Given que el usuario perdió acceso a su segundo factor
    When solicita recuperación y valida identidad con "<metodo>"
    Then el sistema permite desactivar o reconfigurar el 2FA de forma segura
    Examples:
      | metodo         |
      | códigos de respaldo |
      | verificación por correo |


Feature: HU-27S - Control de datos compartidos
  Como ciudadano, quiero decidir qué datos comparto con la comunidad,
  para mantener mi privacidad.

  Scenario Outline: Configuración de anonimato en publicación
    Given que el usuario va a publicar en la comunidad
    When configura anonimato "<opcion>"
    Then la app publica el contenido respetando la visibilidad elegida
    Examples:
      | opcion                  |
      | ocultar nombre          |
      | ocultar ubicación exacta|

  Scenario Outline: Modo privado para compartir contenido
    Given que el usuario activa el modo privado
    When comparte "<tipo_contenido>"
    Then la aplicación mantiene su identidad anónima
    Examples:
      | tipo_contenido |
      | reporte        |
      | comentario     |

  Scenario Outline: Vista previa antes de publicar
    Given que el usuario va a compartir un contenido
    When revisa la vista previa
    Then la aplicación muestra cómo aparecerá "<visibilidad>"
    Examples:
      | visibilidad |
      | pública     |
      | anónima     |

  Scenario Outline: Modificación posterior de permisos
    Given que el usuario ya compartió información
    When edita los permisos a "<nuevo_estado>"
    Then la app actualiza la visibilidad aplicada al contenido
    Examples:
      | nuevo_estado |
      | público      |
      | privado      |


Feature: HU-28S - Eliminación de cuenta y datos
  Como usuario, quiero poder eliminar mi cuenta y datos asociados,
  para tener control total sobre mi información personal.

  Scenario Outline: Eliminación definitiva de cuenta
    Given que el usuario solicita eliminar su cuenta
    When confirma la eliminación con "<mecanismo>"
    Then la aplicación elimina permanentemente los datos
    Examples:
      | mecanismo  |
      | contraseña |
      | 2FA        |

  Scenario Outline: Periodo de gracia para recuperación
    Given que existe un periodo de gracia de "<dias>" días
    When el usuario solicita recuperar la cuenta dentro del periodo
    Then la aplicación restaura los datos
    Examples:
      | dias |
      | 15   |

  Scenario Outline: Eliminación selectiva de datos
    Given que el usuario no desea cerrar su cuenta
    When solicita eliminar únicamente "<dato>"
    Then la aplicación elimina la información seleccionada
    Examples:
      | dato            |
      | historial       |
      | medios subidos  |


Feature: HU-29S - Acceso restringido para administradores
  Como usuario, quiero que solo administradores autorizados puedan ver datos sensibles,
  para garantizar que no se usen indebidamente.

  Scenario Outline: Acceso autorizado a datos sensibles
    Given que el usuario es administrador autorizado e inició sesión
    When solicita acceder a "<recurso>"
    Then el sistema muestra la información completa
    Examples:
      | recurso          |
      | datos sensibles  |
      | auditorías       |

  Scenario Outline: Acceso denegado a no administradores
    Given que el usuario no tiene privilegios de administrador
    When intenta acceder a "<recurso>"
    Then el sistema bloquea el acceso y no revela ningún dato
    Examples:
      | recurso          |
      | datos sensibles  |
      | auditorías       |

  Scenario Outline: Acceso desde dispositivo no autorizado
    Given que el intento proviene de un dispositivo "<estado>"
    When introduce credenciales y solicita ver datos sensibles
    Then el sistema bloquea el acceso y registra el intento
    Examples:
      | estado         |
      | no registrado  |
      | no verificado  |


Feature: HU-30S - Actualizaciones de seguridad automáticas
  Como usuario, quiero que la app reciba actualizaciones de seguridad automáticas,
  para protegerme de vulnerabilidades sin hacer nada manual.

  Scenario Outline: Actualización automática al estar en línea
    Given que hay una nueva versión de seguridad disponible
    When el usuario "<accion>"
    Then la aplicación actualiza automáticamente los módulos de seguridad
    Examples:
      | accion                              |
      | conecta el dispositivo a internet   |
      | abre la app con conexión            |

  Scenario Outline: Aviso de actualización manual
    Given que la app no puede actualizarse automáticamente
    When el usuario abre la app y la actualización está pendiente
    Then la app avisa para realizar la actualización manualmente
    Examples:
      |                                      |
      |                                      |

  Scenario Outline: Registro de actualizaciones
    Given que el usuario desea conocer el historial de actualizaciones
    When entra a "<ruta>"
    Then el sistema muestra la fecha de la última actualización aplicada
    Examples:
      | ruta                       |
      | Configuración > Seguridad  |

  Scenario Outline: Verificación de compatibilidad de versiones
    Given que el sistema recibe una actualización
    When se instala la nueva versión o se reinicia la app tras actualizarse
    Then la aplicación verifica compatibilidad y muestra el resultado
    Examples:
      |                          |
      |                          |


Feature: HU-31C - Edición de publicaciones de incidentes
  Como comerciante/residente, deseo editar una publicación para corregir o ampliar información.

  Scenario Outline: Edición básica
    Given que el autor está en "Editar publicación"
    When modifica "<campo>" y guarda
    Then el sistema muestra la publicación actualizada con etiqueta "Editado"
    Examples:
      | campo       |
      | título      |
      | descripción |
      | imágenes    |
      | ubicación   |

  Scenario Outline: Restricción por verificación o bloqueo
    Given que la publicación está en estado "<estado>"
    When el autor intenta editar
    Then el sistema impide la edición y muestra el mensaje correspondiente
    Examples:
      | estado    |
      | Verificada|
      | Bloqueada |

  Scenario Outline: Edición sin conexión
    Given que no hay conexión a internet
    When el autor guarda cambios
    Then el sistema marca como "Pendiente de sincronización"
    Examples:
      |          |
      |          |


Feature: HU-32C - Eliminación de publicaciones
  Como comerciante/residente, deseo eliminar mis publicaciones y poder restaurarlas en 48 horas.

  Scenario Outline: Eliminación definitiva
    Given que el usuario está en "Mis publicaciones"
    When confirma la eliminación de la publicación "<id>"
    Then el sistema la elimina y deja de mostrarse en listados en 2 días
    Examples:
      | id   |
      | 101  |
      | 205  |

  Scenario Outline: Cancelar eliminación durante el periodo
    Given que la publicación fue eliminada y no han pasado 48 horas
    When el usuario selecciona "Cancelar eliminación"
    Then la publicación vuelve a estar disponible
    Examples:
      |        |
      |        |


Feature: HU-33C - Borradores de publicaciones
  Como comerciante/residente, deseo guardar borradores para retomarlos después.

  Scenario Outline: Guardar borrador
    Given que el usuario está creando una nueva publicación
    When presiona "Guardar borrador"
    Then el sistema guarda el borrador y muestra "Borrador guardado"
    Examples:
      |                           |
      |                           |

  Scenario Outline: Recuperar borrador
    Given que existen borradores guardados
    When el usuario abre "Borradores"
    Then el sistema lista los borradores y permite continuar la edición
    Examples:
      |                   |
      |                   |

  Scenario Outline: Eliminar borrador
    Given que el usuario desea descartar un borrador
    When selecciona "Eliminar borrador"
    Then el sistema elimina el borrador y ya no aparece en el listado
    Examples:
      |                 |
      |                 |


# --- HU-34+ (inferidas para completar hasta HU-50C) ---

Feature: HU-34S - Gestión de sesiones en múltiples dispositivos
  Scenario Outline: Cerrar sesión en otros dispositivos
    Given que el usuario tiene sesiones activas en "<cantidad>" dispositivos
    When selecciona "Cerrar sesiones en otros dispositivos"
    Then todas las sesiones excepto la actual se cierran
    Examples:
      | cantidad |
      | 2        |
      | 3        |

Feature: HU-35S - Exportación de datos personales
  Scenario Outline: Solicitar exportación de datos
    Given que el usuario está autenticado
    When solicita exportar sus datos en formato "<formato>"
    Then el sistema prepara el archivo y envía un enlace de descarga
    Examples:
      | formato |
      | JSON   |
      | CSV    |

Feature: HU-36S - Consentimiento granular por finalidad
  Scenario Outline: Gestionar consentimientos
    Given que el usuario abre Configuración > Privacidad > Consentimientos
    When activa o desactiva el consentimiento para "<finalidad>"
    Then el sistema registra el cambio con marca de tiempo
    Examples:
      | finalidad          |
      | analítica          |
      | notificaciones     |

Feature: HU-37S - Revocación de consentimientos
  Scenario Outline: Revocar y verificar efectos
    Given que el usuario revoca el consentimiento de "<finalidad>"
    When vuelve a la pantalla principal
    Then la app deja de procesar datos para esa finalidad
    Examples:
      | finalidad      |
      | analítica      |
      | marketing      |

Feature: HU-38S - Reporte responsable de vulnerabilidades
  Scenario Outline: Enviar reporte de seguridad
    Given que el usuario detectó una vulnerabilidad
    When completa el formulario con severidad "<sev>"
    Then el sistema registra el caso y entrega un ID de seguimiento
    Examples:
      | sev  |
      | alta |
      | media|

Feature: HU-39C - Denuncia anónima a autoridades
  Scenario Outline: Enviar denuncia anónima
    Given que el usuario selecciona "Denuncia anónima"
    When llena el formulario con tipo "<tipo>"
    Then la app envía la denuncia a la autoridad competente
    Examples:
      | tipo    |
      | robo    |
      | acoso   |

Feature: HU-40C - Etiquetas y categorías en reportes
  Scenario Outline: Asignar categoría y etiquetas
    Given que el usuario crea un reporte
    When selecciona categoría "<categoria>" y etiquetas "<tags>"
    Then el reporte se clasifica y es filtrable
    Examples:
      | categoria | tags                 |
      | robo      | noche,arma blanca    |
      | vandalismo| graffiti,daños       |

Feature: HU-41C - Seguimiento del estado de reportes
  Scenario Outline: Cambiar estado del reporte
    Given que el reporte tiene estado "<estado_inicial>"
    When la autoridad actualiza a "<estado_final>"
    Then los suscriptores reciben notificación de cambio
    Examples:
      | estado_inicial | estado_final |
      | nuevo          | en revisión  |
      | en revisión    | resuelto     |

Feature: HU-42C - Adjuntar evidencia multimedia
  Scenario Outline: Subir evidencia
    Given que el usuario crea un reporte
    When adjunta "<tipo>" de tamaño "<tam>"
    Then el sistema valida y adjunta la evidencia
    Examples:
      | tipo  | tam  |
      | foto  | 2MB  |
      | video | 15MB |

Feature: HU-43C - Menciones y notificaciones en comunidad
  Scenario Outline: Mencionar usuarios
    Given que el usuario escribe un comentario
    When menciona a "<usuario>"
    Then el mencionado recibe notificación
    Examples:
      | usuario   |
      | @vecino01 |
      | @sereno02 |

Feature: HU-44C - Reacciones rápidas en publicaciones
  Scenario Outline: Enviar reacción
    Given que el usuario visualiza una publicación
    When selecciona la reacción "<reaccion>"
    Then el contador de reacciones se actualiza
    Examples:
      | reaccion  |
      | útil      |
      | alerta    |

Feature: HU-45P - Compartir trayecto con autoridad/Contacto
  Scenario Outline: Compartir trayecto seguro
    Given que el usuario inicia un trayecto seguro
    When decide compartir con "<destinatario>"
    Then el destinatario ve ubicación en tiempo real
    Examples:
      | destinatario        |
      | autoridad           |
      | contacto de confianza |

Feature: HU-46M - Capas de mapa (oficial/comunitario)
  Scenario Outline: Alternar capas
    Given que el usuario abre el mapa
    When activa la capa "<capa>"
    Then el mapa actualiza la visualización
    Examples:
      | capa       |
      | oficial    |
      | comunitaria|

Feature: HU-47M - Filtros temporales en mapa de calor
  Scenario Outline: Aplicar filtro por rango
    Given que el usuario está en Mapa de calor
    When aplica rango "<rango>"
    Then el mapa muestra incidencias del periodo
    Examples:
      | rango     |
      | 7 días    |
      | 30 días   |

Feature: HU-48C - Moderación asistida por ML
  Scenario Outline: Marcar reporte sospechoso
    Given que el sistema evalúa el contenido automáticamente
    When detecta probabilidad "<prob>" de falsedad
    Then marca el reporte como "sospechoso" para revisión
    Examples:
      | prob |
      | alta |
      | media|

Feature: HU-49S - Registro de auditoría descargable
  Scenario Outline: Descargar auditoría
    Given que el usuario administrador accede a Auditoría
    When solicita exportar "<periodo>"
    Then el sistema genera un archivo descargable
    Examples:
      | periodo   |
      | último mes|
      | último trimestre |

Feature: HU-50C - Bloqueo y reporte de usuarios
  Scenario Outline: Bloquear y reportar
    Given que el usuario visualiza el perfil "<usuario>"
    When selecciona "Bloquear" y "Reportar" con motivo "<motivo>"
    Then el usuario queda bloqueado y se crea un ticket de moderación
    Examples:
      | usuario   | motivo       |
      | @troll01  | acoso        |
      | @spam_233 | spam         |
