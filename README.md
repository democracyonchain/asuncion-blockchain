<div align="center">
  <a href="https://aiken-lang.org/" target="_blank">    
    <img src="https://raw.githubusercontent.com/aiken-lang/branding/main/assets/logo-dark.png" width="190" alt="BlockFrost Logo" />
  </a>
</div>
<div align="center"> 
  <a href="https://dotnet.microsoft.com/apps/aspnet" target="_blank">
    <img src="https://img.shields.io/badge/Aiken lang-1.1.4-blue" alt=".NET Framework Version">
  </a>  
</div>


# asuncion_sc

### English Version

## Blockchain Component for the Voting System

This component is a part of the **Blockchain Voting System**, which aims to integrate blockchain technology into the vote-counting system to enhance **security** and **transparency** in election processes.

### Summary

The `asuncion_sc` module for the Blockchain Voting System facilitates the blockchain-based verification and storage of voting records. It adds a critical layer to the traditional Latin American voting process by making it auditable, secure, and accessible on the blockchain. The module performs the following tasks:

1. Manages the state of voting records (`Actas`) throughout each stage: scanning, intelligent recognition, digitization, and quality control.
2. Secures each record by creating and storing hashes on the Cardano blockchain.
3. Enables decentralized storage of images, depending on factors such as cost and decentralized storage options compatible with Cardano.

### Key Features

- **State Management**: Tracks each voting record’s progress through scanning, intelligent recognition, digitization, and quality control.
- **Blockchain Hashing**: Publishes unique hashes to the Cardano blockchain for verification at every stage.
- **IPFS Integration**: Allows decentralized storage of images when feasible.

### Process Flow

1. **Scanning**: Digitizes the voting record, generating a hash stored on the blockchain.
2. **Intelligent Recognition**: Recognizes characters in each segmented image section, assigning votes to candidates on the blockchain.
3. **Digitization**: "Digitators" validate and enter votes based on segments, verifying each hash on the blockchain.
4. **Quality Control**: Ensures the accuracy of votes through a "2 out of 3" validation approach.

### Prerequisites

- **Cardano Blockchain Knowledge**
- **Aiken Language Familiarity**

### Installation Procedure

1. Clone the repository:  
```plaintext
$ git clone https://github.com/democracyonchain/asuncion-sc.git
```
2. Build the Aiken scripts using:
```sh
aiken build
```

3. Run all checks to validate functionality:
```sh
aiken check
```

### Usage

Write validators in the `validators` folder, and supporting functions in the `lib` folder using `.ak` as a file extension.

Example validator (`validators/always_true.ak`):

```gleam
validator {
  fn spend(_datum: Data, _redeemer: Data, _context: Data) -> Bool {
    True
  }
}
```

### Documentation

To generate HTML documentation, use:

```sh
aiken docs
```

### Resources

Find more on [Aiken's user manual](https://aiken-lang.org).

---

### Spanish Version

## Componente Blockchain para el Sistema de Votación

Este componente forma parte del **Sistema de Votación en Blockchain** y está diseñado para integrar tecnología blockchain en el sistema de conteo de votos, brindando **seguridad** y **transparencia** en los procesos electorales.

### Resumen

El módulo `asuncion_sc` del Sistema de Votación en Blockchain permite la verificación y almacenamiento de actas de votación en la blockchain de manera segura y auditable. Este módulo cumple las siguientes funciones:

1. Gestiona el estado de las actas de votación (`Actas`) a lo largo de cada etapa: escaneo, reconocimiento inteligente, digitación y control de calidad.
2. Asegura cada acta mediante la creación y almacenamiento de hashes en la blockchain de Cardano.
3. Permite el almacenamiento descentralizado de imágenes, según factores como costo y opciones de almacenamiento compatibles con Cardano.

### Características Principales

- **Gestión de Estado**: Monitorea el progreso de cada acta en las fases de escaneo, reconocimiento inteligente, digitación y control de calidad.
- **Hashing en Blockchain**: Publica hashes únicos en la blockchain de Cardano para verificación en cada etapa.
- **Integración con IPFS**: Permite almacenamiento descentralizado de imágenes cuando sea viable.

### Flujo del Proceso

1. **Escaneo**: Digitaliza el acta, generando un hash almacenado en la blockchain.
2. **Reconocimiento Inteligente**: Reconoce caracteres en cada sección segmentada de la imagen, asignando votos a candidatos en la blockchain.
3. **Digitación**: Los "digitadores" validan e ingresan votos según los segmentos, verificando cada hash en la blockchain.
4. **Control de Calidad**: Asegura la precisión de los votos mediante una validación "2 de 3".

### Requisitos Previos

- **Conocimiento de Blockchain en Cardano**
- **Familiaridad con el Lenguaje Aiken**

### Procedimiento de Instalación

1. Clonar el repositorio:  
```plaintext
$ git clone https://github.com/democracyonchain/asuncion-sc.git
```
2. Construya los scripts de Aiken usando:
```sh
aiken build
```

3. Ejecute todas las verificaciones para validar la funcionalidad:
```sh
aiken check
```

### Uso

Escriba validadores en la carpeta `validators` y funciones de soporte en la carpeta `lib` usando la extensión `.ak`.

Ejemplo de validador (`validators/always_true.ak`):

```gleam
validator {
  fn spend(_datum: Data, _redeemer: Data, _context: Data) -> Bool {
    True
  }
}
```

### Documentación

Para generar documentación en HTML, use:

```sh
aiken docs
```

### Recursos

Encuentra más en el [manual de usuario de Aiken](https://aiken-lang.org).
