use aiken/collection/list.{any, has, is_empty as list_is_empty}
use aiken/crypto.{VerificationKeyHash}
use aiken/primitive/bytearray.{is_empty}
use cardano/transaction.{OutputReference, Transaction}

// Declarar todos los tipos utilizados en el validador como públicos
pub type EstadoActa =
  Int

// 0 - Estado inicial / Initial state
// 1 - Acta escaneada / Scanned ballot
// 2 - Acta digitada / Digitized ballot
// 3 - Acta verificada / Verified ballot

pub type Candidato =
  Int

pub type IpfsUrl =
  ByteArray

pub type Acta {
  id: ByteArray,
  // Código único del acta / Unique ballot code
  timestamp: Int,
  // Timestamp de la transacción / Transaction timestamp
  estado: EstadoActa,
  // Estado actual del acta / Current ballot status
  imagen_acta: IpfsUrl,
  // Dirección IPFS del acta completa / Complete ballot IPFS address    
  user_id: Int,
  // ID del usuario que escaneó/digitó/verificó el acta / User ID who scanned/digitized/verified the ballot
  hash_anterior: ByteArray,
  // Hash anterior del acta / Previous ballot hash
  segmentos: List<IpfsCandidatoUrl>,
  // Lista de segmentos del acta / List of ballot segments
  votos: List<Votos>,
}

// Lista de votos del acta / List of ballot votes

// Lista de votos por candidato / List of votes per candidate

pub type IpfsCandidatoUrl {
  candidato: Candidato,
  // Código del candidato / Candidate code
  ipfs_seccion: ByteArray,
}

// Dirección IPFS de la sección del acta / Ballot section IPFS address

pub type Votos {
  candidato: Candidato,
  // Código del candidato / Candidate code    
  voto: Int,
}

// Votos que recibió el candidato / Votes received by candidate

// Función general para validar el acta
fn validar_acta(acta: Acta, redeemer: Int, tx_info: Transaction) -> Bool {
  // Validaciones básicas comunes a todos los estados
  let usuario_valido = validar_user_id(acta) && acta.user_id == redeemer
  let codigo_valido = validar_codigo_acta(acta)
  let timestamp_valido = validar_timestamp(acta)
  let estado_valido = validar_estado(acta)
  let hash_valido = validar_hash_anterior(acta)
  // Validación de la dirección autorizada
  let direccion_autorizada = authorized_address_for_state(acta.estado)
  let direccion_valida =
    validar_direccion_transaccion(tx_info, direccion_autorizada)
  // Resultado de validaciones básicas
  usuario_valido && codigo_valido && timestamp_valido && estado_valido && hash_valido && direccion_valida
}

// Función para validar la dirección de la transacción
fn validar_direccion_transaccion(
  tx_info: Transaction,
  direccion_autorizada: VerificationKeyHash,
) -> Bool {
  // Verificar si la dirección autorizada es una de las firmantes
  has(tx_info.extra_signatories, direccion_autorizada)
}

// Validador para el proceso de escaneo inicial del acta
// Validator for initial ballot scanning process
validator escaneo_acta {
  spend(
    datum: Option<Acta>,
    redeemer: Int,
    _target: OutputReference,
    tx_info: Transaction,
  ) {
    expect Some(acta) = datum
    // Validar que está en el estado correcto para escaneo
    let estado_correcto = acta.estado == 1
    // Validar que tiene imagen del acta
    let imagen_valida = !is_empty(acta.imagen_acta)
    // Validaciones generales + específicas de escaneo
    let tiene_segmentos = validar_segmentos(acta)
    // Validar que los segmentos estén presentes
    let tiene_votos = validar_votos(acta)
    // Validar que los votos estén presentes
    validar_acta(acta, redeemer, tx_info) && estado_correcto && imagen_valida && validar_IPFS(
      acta,
    ) && tiene_segmentos && tiene_votos
  }

  else(_) {
    fail
  }
}

// Validador para el proceso de digitación
validator digitacion_acta {
  spend(
    datum: Option<Acta>,
    redeemer: Int,
    _target: OutputReference,
    tx_info: Transaction,
  ) {
    expect Some(acta) = datum
    // Validar que está en el estado correcto para digitación
    let estado_correcto = acta.estado == 2
    // Validar que tiene datos de votos
    let datos_validos = !list_is_empty(acta.votos)
    // Validar candidatos especiales
    let candidatos_especiales = validar_candidatos_especiales(acta.votos)
    // Validaciones generales + específicas de digitación
    let tiene_segmentos_acta = validar_segmentos(acta)
    // Validar que los segmentos estén presentes
    let tiene_segmentos_especiales =
      validar_segmentos_especiales(acta.segmentos)
    // Validar que los segmentos especiales estén presentes
    let validar_hash_anterior = validar_hash_anterior(acta)
    // Validar que el hash anterior esté presente
    validar_acta(acta, redeemer, tx_info) && estado_correcto && datos_validos && candidatos_especiales && tiene_segmentos_especiales && validar_hash_anterior && tiene_segmentos_acta
  }

  else(_) {
    fail
  }
}

// Validador para el control de calidad
validator control_calidad_acta {
  spend(
    datum: Option<Acta>,
    redeemer: Int,
    _target: OutputReference,
    tx_info: Transaction,
  ) {
    expect Some(acta) = datum
    // Validar que está en el estado correcto para control de calidad
    let estado_correcto = acta.estado == 3
    // Validar que tiene datos de votos
    let datos_validos = !list_is_empty(acta.votos)
    // Validar candidatos especiales  
    let validar_hash_anterior = validar_hash_anterior(acta)
    // Validar que el hash anterior esté presente
    validar_acta(acta, redeemer, tx_info) && estado_correcto && datos_validos && validar_hash_anterior
  }

  else(_) {
    fail
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

// Validar que el estado sea válido (1 a 4)
fn validar_estado(acta: Acta) -> Bool {
  acta.estado > 0 && acta.estado <= 4
}

// Validar que el hash anterior esté presente
fn validar_hash_anterior(acta: Acta) -> Bool {
  !is_empty(acta.hash_anterior)
}

// Función para validar candidatos especiales
fn validar_segmentos_especiales(datos: List<IpfsCandidatoUrl>) -> Bool {
  let tiene_votantes = any(datos, fn(segmento) { segmento.candidato == 11111 })
  let tiene_blancos = any(datos, fn(segmento) { segmento.candidato == 22222 })
  let tiene_nulos = any(datos, fn(segmento) { segmento.candidato == 33333 })
  tiene_votantes && tiene_blancos && tiene_nulos
}

// Función para validar candidatos especiales
fn validar_candidatos_especiales(datos: List<Votos>) -> Bool {
  let tiene_votantes = any(datos, fn(voto) { voto.candidato == 11111 })
  let tiene_blancos = any(datos, fn(voto) { voto.candidato == 22222 })
  let tiene_nulos = any(datos, fn(voto) { voto.candidato == 33333 })
  tiene_votantes && tiene_blancos && tiene_nulos
}

// Validar que el campo de IPFS esté presente y cumpla con las condiciones según el estado
fn validar_IPFS(acta: Acta) -> Bool {
  when acta.estado is {
    1 -> !is_empty(acta.imagen_acta)
    // En estado Escaneado, `imagen_acta` debe tener datos
    2 -> True
    // La imagen es opcional en estado OCR
    3 -> True
    // La imagen es opcional en estado Digitado
    4 -> True
    // La imagen es opcional en estado Control de Calidad
    _ -> False
  }
  // Otros estados no son válidos
}

// Validar que los segmentos estén presentes según el estado
fn validar_segmentos(acta: Acta) -> Bool {
  when acta.estado is {
    1 ->
      !list_is_empty(acta.segmentos) && validar_segmentos_especiales(
        acta.segmentos,
      )
    // En estado escaneo, `segmentos` debe tener datos
    _ -> True
  }
}

// Validar que los votos estén presentes según el estado
fn validar_votos(acta: Acta) -> Bool {
  when acta.estado is {
    // En estado Escaneo, `datos` debe tener datos y tambien debe tener datos de votos especiales
    1 -> !list_is_empty(acta.votos) && validar_candidatos_especiales(acta.votos)
    // En estado digitación, `datos` debe tener datos y tambien debe tener datos de votos especiales
    2 -> !list_is_empty(acta.votos) && validar_candidatos_especiales(acta.votos)
    // 
    3 -> !list_is_empty(acta.votos)
    _ -> True
  }
}

fn authorized_address_for_state(estado: EstadoActa) -> VerificationKeyHash {
  when estado is {
    0 -> "addr_test1vqe4xtnexf86tj4szd692mfn6huehaqqcarp8nm4uhqrwwsjzlqmd"
    // Dirección para estado inicial
    1 -> "addr_test1vqe4xtnexf86tj4szd692mfn6huehaqqcarp8nm4uhqrwwsjzlqmd"
    // Dirección para escaneo
    2 -> "addr_test1vqe4xtnexf86tj4szd692mfn6huehaqqcarp8nm4uhqrwwsjzlqmd"
    // Dirección para OCR
    3 -> "addr_test1vqe4xtnexf86tj4szd692mfn6huehaqqcarp8nm4uhqrwwsjzlqmd"
    // Dirección para digitación
    4 -> "addr_test1vqe4xtnexf86tj4szd692mfn6huehaqqcarp8nm4uhqrwwsjzlqmd"
    // Dirección para verificación
    _ -> fail
  }
}
