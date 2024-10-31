use aiken/collection/list.{is_empty as list_is_empty, any}
use aiken/primitive/bytearray.{is_empty}
use cardano/transaction.{Transaction, OutputReference}

// Declarar todos los tipos utilizados en el validador como públicos
pub type EstadoActa = Int
// 0 - Estado inicial / Initial state
// 1 - Acta escaneada / Scanned ballot
// 2 - Acta digitada / Digitized ballot
// 3 - Acta verificada / Verified ballot

pub type Candidato = Int
pub type IpfsUrl = ByteArray

pub type Acta {
    id: ByteArray,                 // Código único del acta / Unique ballot code
    timestamp: Int,                // Timestamp de la transacción / Transaction timestamp
    estado: EstadoActa,           // Estado actual del acta / Current ballot status
    imagen_acta: IpfsUrl,          // Dirección IPFS del acta completa / Complete ballot IPFS address    
    user_id: Int,                  // ID del usuario que escaneó/digitó/verificó el acta / User ID who scanned/digitized/verified the ballot
    hash_anterior: ByteArray,      // Hash anterior del acta / Previous ballot hash
    segmentos: List<IpfsCandidatoUrl>,  // Lista de segmentos del acta / List of ballot segments
    datos: List<Votos>             // Lista de votos por candidato / List of votes per candidate
}

pub type IpfsCandidatoUrl {
    candidato: Candidato,          // Código del candidato / Candidate code
    ipfs_seccion: ByteArray        // Dirección IPFS de la sección del acta / Ballot section IPFS address
}

pub type Votos {
    candidato: Candidato,          // Código del candidato / Candidate code    
    voto: Int                      // Votos que recibió el candidato / Votes received by candidate
}

// Validador para validar la estructura del acta. / Validator to validate the ballot structure.
validator datos_acta() {
  // Manejador `spend` para validar la estructura del `Acta`
  spend(datum: Option<Acta>, redeemer: Int, _target: OutputReference, tx_info: Transaction) {
      expect Some(acta) = datum

      // Validaciones necesarias para asegurar que el acta es válida.
      let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
      let codigo_valido = validar_codigo_acta(acta)
      let timestamp_valido = validar_timestamp(acta)
      let estado_valido = validar_estado(acta)
      let hash_valido = validar_hash_anterior(acta)
      let datos_valido = validar_datos(acta)
      let ipfs_valido = validar_IPFS(acta)
      let segmentos_valido = validar_segmentos(acta)
      let candidatos_especiales_valido = validar_candidatos_especiales(acta.datos)

      // Validación final que asegura que todos los criterios se cumplen.
      usuario_valido 
      && codigo_valido 
      && timestamp_valido 
      && estado_valido 
      && hash_valido 
      && datos_valido 
      && ipfs_valido 
      && segmentos_valido 
      && candidatos_especiales_valido
  }
}

// Validador para el proceso de escaneo inicial del acta
// Validator for initial ballot scanning process
validator escaneo_acta() {
   spend(datum: Option<Acta>, redeemer: Int, _target: OutputReference, tx_info: Transaction) -> Bool {
        expect Some(acta) = datum
        
        // Utiliza la función existente validar_escaneo
        validar_escaneo(acta, redeemer)
    }
}

// Validador para el proceso de OCR
// Validator for OCR process
validator ocr_acta() {
    spend(datum: Option<Acta>, redeemer: Int, _target: OutputReference, tx_info: Transaction) -> Bool {
        expect Some(acta) = datum
        
        // Validar usuario y proceso OCR
        let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
        let ocr_valido = validar_ocr(acta)
        
        usuario_valido && ocr_valido
    }
}

// Validador para el proceso de digitación
// Validator for digitization process
validator digitacion_acta() {
    spend(datum: Option<Acta>, redeemer: Int, _target: OutputReference, tx_info: Transaction) -> Bool {
        expect Some(acta) = datum
        
        // Validar usuario y proceso de digitación
        let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
        let digitacion_valida = validar_digitacion(acta)
        
        usuario_valido && digitacion_valida
    }
}

// Validador para el control de calidad
// Validator for quality control process
validator control_calidad_acta() {
    spend(datum: Option<Acta>, redeemer: Int, _target: OutputReference, tx_info: Transaction) -> Bool {
        expect Some(acta) = datum
        
        // Validar usuario y control de calidad
        let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
        let calidad_valida = validar_control_calidad(acta)
        
        usuario_valido && calidad_valida
    }
}


fn validar_ocr(acta: Acta) -> Bool {
    let estado_valido = acta.estado == 2  // Asegurarse de que está en estado "OCR"
    let imagen_valida = !is_empty(acta.imagen_acta)
    let segmentos_validos = validar_segmentos(acta)

    estado_valido 
    && imagen_valida 
    && segmentos_validos
}



fn validar_digitacion(acta: Acta) -> Bool {
    let estado_valido = acta.estado == 3  // Asegurarse de que está en estado "Digitado"
    let datos_validos = validar_datos(acta)
    let segmentos_validos = validar_segmentos(acta)
    let candidatos_especiales = validar_candidatos_especiales(acta.datos)

    estado_valido 
    && datos_validos 
    && segmentos_validos 
    && candidatos_especiales
}


fn validar_control_calidad(acta: Acta) -> Bool {
    let estado_valido = acta.estado == 4  // Asegurarse de que está en estado "Verificado"
    let datos_validos = validar_datos(acta)
    let hash_valido = validar_hash_anterior(acta)
    let candidatos_especiales = validar_candidatos_especiales(acta.datos)

    estado_valido 
    && datos_validos 
    && hash_valido 
    && candidatos_especiales
}


fn validar_escaneo(acta: Acta, redeemer: Int) -> Bool {
    let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
    let codigo_valido = validar_codigo_acta(acta)
    let timestamp_valido = validar_timestamp(acta)
    let estado_valido = acta.estado == 1  // Asegurarse de que está en estado "escaneado"
    let imagen_valida = !is_empty(acta.imagen_acta)

    usuario_valido 
    && codigo_valido 
    && timestamp_valido 
    && estado_valido 
    && imagen_valida
}



// Función para validar candidatos especiales
fn validar_candidatos_especiales(datos: List<Votos>) -> Bool {
    let tiene_votantes = any(datos, fn(voto) { voto.candidato == 11111 })
    let tiene_blancos = any(datos, fn(voto) { voto.candidato == 2222 })
    let tiene_nulos = any(datos, fn(voto) { voto.candidato == 11111 })
    
    tiene_votantes && tiene_blancos && tiene_nulos
}

// Validar que el campo de IPFS esté presente y cumpla con las condiciones según el estado
fn validar_IPFS(acta: Acta) -> Bool {
   when acta.estado is
      {       
         1 -> !is_empty(acta.imagen_acta)           // En estado Escaneado, `imagen_acta` debe tener datos
         2 -> !list_is_empty(acta.segmentos)        // En estado OCR, `segmentos` debe tener datos
         3 -> !list_is_empty(acta.datos)            // En estado Digitado, `datos` debe estar presente
         4 -> !list_is_empty(acta.datos)            // En estado Verificado, `datos` debe estar presente
          _ -> False                                 // Otros estados no son válidos
      }
}

// Validar el código único del acta (no vacío)
fn validar_codigo_acta(acta: Acta) -> Bool {
  !is_empty(acta.id)
}

// Validar que el usuario tenga un ID válido
fn validar_user_id(acta: Acta) -> Bool {
  acta.user_id > 0
}

// Validar que el timestamp sea válido
fn validar_timestamp(acta: Acta) -> Bool {
  acta.timestamp > 0
}

// Validar que el estado sea válido (1 a 3)
fn validar_estado(acta: Acta) -> Bool {
  acta.estado > 0 && acta.estado < 4  
}

// Validar que los segmentos estén presentes según el estado
fn validar_segmentos(acta: Acta) -> Bool {
  when acta.estado is
      {       
         2 -> !list_is_empty(acta.segmentos)           // En estado OCR, `segmentos` debe tener datos
          _ -> False                                    // Otros estados no son válidos
      }
}

// Validar que el hash anterior esté presente
fn validar_hash_anterior(acta: Acta) -> Bool {
 !is_empty(acta.hash_anterior)
}

// Validar que el campo datos esté presente según el estado
fn validar_datos(acta: Acta) -> Bool {
 !list_is_empty(acta.datos)
}
