# Presupuesto del Tesoro 2026 de Harmonic Laboratories

> [!NOTE]
> El siguiente documento es una propuesta para sostener los esfuerzos de Harmonic Laboratories (HLabs) en el mantenimiento y la evolución de la infraestructura de código abierto de Cardano.
>
> Está concebido como punto de partida para la discusión sobre retiros del tesoro de Cardano.
>
> Por lo tanto, invitamos a cualquier persona interesada a comentar este documento y compartir su retroalimentación con nosotros.

## Visión

Harmonic Laboratories (HLabs para abreviar) es una empresa de I+D nacida y enfocada exclusivamente en el ecosistema de Cardano.

Harmonic Laboratories apoya y mantiene una porción considerable de las herramientas TypeScript para el ecosistema de Cardano, que la mayoría de los desarrolladores de Cardano utilizan, ya sea directamente o indirectamente a través de otras bibliotecas que dependen del código escrito y mantenido por HLabs.

La misión de HLabs es que la verdadera descentralización se convierta en la base del desarrollo de aplicaciones, no solo una característica deseable.

Lo hacemos desarrollando y manteniendo infraestructura y herramientas fundamentales.

## Resumen Ejecutivo

Antes de profundizar en los detalles y el desglose de costos, aquí presentamos una vista de alto nivel de la solicitud, algunas suposiciones que estamos haciendo y la dirección general de este presupuesto.

#### Retrospectiva 2025

Proporcionamos una [retrospectiva completa de nuestra hoja de ruta 2025](#2025-Retrospective) en el anexo de este documento. Esto incluye una comparación directa con los elementos de la hoja de ruta presentados el año pasado junto con sus entregas correspondientes.

#### Duración y Hitos

Esta propuesta abarca **12 meses**, durante los cuales habrá varias entregas y demostraciones. Entre las entregas clave, destacamos:

- un mantenimiento de hard fork próximo;
- un nodo con capacidad de relay (Gerolamo);
- un lenguaje de programación para smart contracts completamente maduro, imperativo y eficiente (Pebble).

### Beneficios para el ecosistema

Gerolamo, Pebble y el mantenimiento continuo de herramientas sirven cada uno a distintos grupos de interés mientras fortalecen colectivamente la infraestructura, la experiencia del desarrollador y la sostenibilidad a largo plazo de Cardano.

#### ¿Quién se beneficiará de Gerolamo?

##### TL;DR

- SPOs para nodos relay
- dApps para aplicaciones con mínima confianza
- wallets para seguridad similar a Daedalus

##### SPOs

Los Operadores de Stake Pools pueden usar Gerolamo como un nodo relay adicional junto a su infraestructura existente. La producción de bloques continúa en su configuración actual, mientras que los relays de Gerolamo añaden diversidad y resiliencia a su pool.

Un panorama diverso de implementaciones de nodos fortalece la resiliencia de la red. Al proporcionar una base de código alternativa para relays, Gerolamo reduce el riesgo de problemas a nivel de toda la red derivados de errores en una sola implementación; un factor crítico para la salud a largo plazo y la descentralización de la red.

##### dApps

Las aplicaciones descentralizadas se benefician enormemente del acceso con mínima confianza a los datos de la blockchain. Actualmente, la mayoría de las dApps dependen de indexadores centralizados o APIs de terceros para consultar el estado de la cadena, introduciendo puntos de fallo y suposiciones de confianza que socavan la filosofía de descentralización.

Gerolamo permite a las dApps ejecutar sus propios nodos ligeros; incluso directamente en el navegador; proporcionando acceso directo y sin necesidad de confianza al libro mayor de Cardano.

Esto significa que las dApps pueden verificar estados de UTxO, validar transacciones y consultar datos de la cadena sin depender de servicios externos. El resultado es una arquitectura de aplicación más resiliente y resistente a la censura, alineada con los principios fundamentales de la descentralización.

##### Wallets ligeras

Las wallets ligeras actuales deben confiar en servidores externos para proporcionar datos precisos de la cadena. Esto crea un compromiso de seguridad: los usuarios ganan comodidad pero sacrifican la capacidad de verificar independientemente sus saldos e historial de transacciones.

Con Gerolamo, los desarrolladores de wallets pueden integrar un nodo ligero directamente en sus aplicaciones, ofreciendo a los usuarios garantías de seguridad similares a Daedalus sin la sobrecarga de ejecutar un nodo completo. Los usuarios pueden verificar sus propios UTxOs, validar transacciones entrantes y mantener plena soberanía sobre sus fondos, todo mientras disfrutan de la experiencia de usuario de una wallet ligera.

#### ¿Quién se beneficiará de Pebble?

##### TL;DR

Desarrolladores que buscan una alternativa a la programación funcional sin sacrificar eficiencia.

El lenguaje pretende ser lo más similar posible a TypeScript, que es un lenguaje ampliamente adoptado en Web2, así como similar a lenguajes usados en otros ecosistemas más maduros, como Solidity en cadenas EVM.

##### Incorporación de desarrolladores Web2

Uno de los mayores desafíos de Cardano es la pronunciada curva de aprendizaje para el desarrollo de smart contracts. Aiken, el lenguaje de smart contracts más ampliamente adoptado en Cardano, aunque una gran mejora en comparación con Haskell, aún requiere familiaridad con paradigmas de programación funcional, conceptos desconocidos para la gran mayoría de desarrolladores a nivel mundial. Esta barrera limita significativamente el grupo de talento que puede contribuir al ecosistema de dApps de Cardano.

Pebble cierra esta brecha ofreciendo una sintaxis y experiencia de desarrollo familiar para los desarrolladores de TypeScript y JavaScript, las comunidades de programación más grandes del mundo. Al reducir la barrera de entrada, Pebble abre el desarrollo de Cardano a millones de desarrolladores que de otro modo se verían disuadidos por la curva de aprendizaje de la programación funcional.

##### Código en cadena eficiente

A pesar de su sintaxis imperativa, Pebble compila a UPLC (Untyped Plutus Core) altamente optimizado. Los desarrolladores no tienen que elegir entre familiaridad y eficiencia: Pebble ofrece ambas. El compilador realiza optimizaciones agresivas para minimizar los costos de ejecución, asegurando que los contratos escritos en Pebble sean competitivos con código Plutus optimizado manualmente, haciéndolos una opción viable para aplicaciones en producción.

##### Experiencia de desarrollo profesional

Las herramientas de Pebble, incluyendo una implementación completa del Language Server Protocol (LSP), CLI con modo watch e integración de depuración mediante sourcemaps, proporcionan una experiencia de desarrollo a la par de ecosistemas maduros. Los desarrolladores pueden disfrutar de autocompletado, reporte de errores en línea, ir a definición y todas las comodidades que esperan de los IDEs modernos. Este conjunto de herramientas de nivel profesional acelera los ciclos de desarrollo y reduce errores, lo que en última instancia conduce a dApps de mayor calidad en Cardano.

#### ¿Quién se beneficiará del mantenimiento de herramientas?

##### TL;DR

Todo el ecosistema puede tener la garantía de que siempre habrá herramientas actualizadas y fáciles de usar a su disposición, sin el temor de tener que rediseñar aplicaciones completas por falta de soporte.

##### Estabilidad a nivel de ecosistema

Las herramientas TypeScript mantenidas por HLabs sustentan una porción significativa del ecosistema de desarrolladores de Cardano. Bibliotecas como `cardano-ledger-ts`, `ouroboros-miniprotocols-ts` y `uplc` son dependencias de numerosos proyectos, tanto directamente como de forma transitiva a través de otras bibliotecas. Cuando un hard fork introduce cambios en el protocolo, estas bibliotecas fundamentales deben actualizarse oportunamente, o los proyectos dependientes enfrentan cambios incompatibles y posibles vulnerabilidades de seguridad.

Al financiar el mantenimiento continuo, el Tesoro asegura que el ecosistema TypeScript permanezca sincronizado con las actualizaciones del protocolo. Los desarrolladores pueden confiar en que sus aplicaciones seguirán funcionando a través de los hard forks sin necesidad de reescrituras de emergencia o tiempos de inactividad prolongados.

##### Reducción del riesgo de fragmentación

Sin mantenimiento dedicado, las bibliotecas críticas corren el riesgo de ser abandonadas, un destino común en los ecosistemas de código abierto.

Las dependencias abandonadas obligan a los equipos a bifurcar y mantener el código por su cuenta (duplicando esfuerzo en todo el ecosistema) o a migrar a soluciones alternativas (fragmentando la comunidad de desarrolladores). Ambos resultados son costosos y desestabilizadores.

El financiamiento sostenido para el mantenimiento de herramientas de HLabs elimina este riesgo, proporcionando al ecosistema una base confiable sobre la cual los desarrolladores pueden construir proyectos a largo plazo con confianza.

### Alineación con Cardano 2030

Esta propuesta apoya directamente el [Marco Estratégico Cardano 2030](https://product.cardano.intersectmbo.org/vision/strategy-2030/), contribuyendo a los KPIs fundamentales y pilares estratégicos como se describe a continuación.

#### Alineación con KPIs Fundamentales

| KPI / Prioridad Estratégica                | Objetivo / Meta 2030           | Contribución de HLabs                                                           |
| :----------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------ |
| **Clientes de nodo completo alternativos** | ≥2 conformes con la especificación | Gerolamo contribuye directamente como una segunda implementación de cliente conforme con la especificación |
| **Disponibilidad Mensual**                 | 99.98%                         | El mantenimiento de hard forks asegura estabilidad del ecosistema en las actualizaciones del protocolo |
| **Vías de migración de desarrolladores** (A.3) | "Más desarrolladores pueden incorporarse" | Pebble proporciona a los desarrolladores EVM/TS una sintaxis familiar para smart contracts en Cardano |

> **Nota**: Las dos primeras filas son KPIs formales de Cardano 2030. La tercera fila corresponde al Pilar Estratégico A.3 (Experiencia del Desarrollador → Educación y migración), que es una prioridad explícita de 2030 pero aún no es un KPI numérico. TVL, transacciones mensuales y MAU son resultados a nivel de ecosistema habilitados por inversiones en infraestructura como esta propuesta; hacemos seguimiento de indicadores de adopción (a continuación) como métricas iniciales que contribuyen a estos resultados.

#### Alineación con Pilares Estratégicos

**Pilar 1: Excelencia en Infraestructura e Investigación**

- **I.2 Seguridad y Resiliencia → Diversidad de Clientes**: Gerolamo está explícitamente alineado con el objetivo 2030 de "apoyar implementaciones adicionales de nodo completo y cliente ligero" para lograr "mejor descentralización" y "reducir el riesgo de cliente único".

**Pilar 2: Adopción y Utilidad**

- **A.3 Experiencia del Desarrollador → Incentivos de código abierto**: Esta propuesta aborda directamente la prioridad estratégica de "incentivar el mantenimiento de SDKs, frameworks e infraestructura central de Cardano en línea con las mejores prácticas de código abierto" para un "ecosistema de constructores sostenible".
- **A.3 Experiencia del Desarrollador → Educación y migración**: Pebble aborda el objetivo de "proporcionar materiales para desarrolladores EVM/basados en cuentas que migran a Cardano/UTxO" ofreciendo una sintaxis imperativa familiar, permitiendo que "más desarrolladores se incorporen".

#### Indicadores de Adopción Medibles

Para proporcionar visibilidad sobre cómo esta propuesta contribuye a los resultados a nivel de ecosistema, nos comprometemos a rastrear e informar los siguientes indicadores de adopción:

##### Objetivos de Adopción de Gerolamo

| Métrica                          | Objetivo a 12 Meses | Método de Medición                     |
| :------------------------------- | :------------------- | :------------------------------------- |
| SPOs ejecutando Gerolamo como relay | ≥10 pools         | Registro público + auto-reporte        |
| Integraciones de nodo en navegador | ≥3 wallets/dApps  | Integraciones de dApps/wallets         |

##### Objetivos de Adopción de Pebble

| Métrica                    | Objetivo a 12 Meses    | Método de Medición                             |
| :------------------------- | :--------------------- | :--------------------------------------------- |
| Incorporación de desarrolladores | ≥20 desarrolladores | Descargas npm, estrellas en GitHub, miembros de Discord |
| Completitud de documentación | 100% de cobertura    | Todas las características del lenguaje documentadas con ejemplos |
| Completitud de tutoriales  | ≥3 tutoriales de extremo a extremo | Guías publicadas cubriendo patrones comunes |

## Desglose del Presupuesto

### Solicitud de Presupuesto Total

La solicitud total para 2026 es de **`₳8,035,714`**, cubriendo un presupuesto en USD de **`$2,250,000`** (o **`₳6,428,571`**) + 25% en contingencia reembolsable (**`₳1,607,143`**).

Esta cifra incluye los costos estimados, así como una contingencia reembolsable, que nos permitirá operar con cierto grado de independencia respecto a la volatilidad del mercado. La contingencia será reembolsada total o parcialmente al tesoro en caso de no ser utilizada.

El desglose completo del presupuesto se presenta a continuación.

Para una valoración justa de la propuesta, seguiremos un proceso similar al utilizado en la propuesta de Amaru, que creemos está estableciendo un buen estándar en términos de propuestas de presupuesto del Tesoro, y estimaremos los alcances de esta propuesta en _FTE_ (Equivalente a Tiempo Completo), que consideraremos igual a una tarifa anual de `$225k`.

Utilizamos una tasa de conversión de `0.35` ADA [`₳`] por USD [`$`].

### Vista Completa

| Alcance                                                   | Estimado (FTEs) | Total del Proyecto ($) |
| :---                                                      | ---:            | ---:                   |
| Gerolamo (nodo Cardano en TypeScript)                     | 5               | `$1,125,000`           |
| Pebble (lenguaje de programación + herramientas de desarrollo de dApps) | 3.5 | `$785,500`          |
| Mantenimiento de hard fork                                | 1.5             | `$337,500`             |
|                                                           |                 |                        |
| **Total**                                                 | **10 FTEs**     | `$2,250,000`           |

El costo fijo estimado incluye:

#### Justificación

La solicitud total para el proyecto es de `10 FTEs`.

Los FTEs se valoran a una tarifa anual de `$225k`.

Además, somos conscientes de nuestro sesgo de suposición/optimismo (nuestra previsión está sujeta a subestimar la complejidad, pasar por alto desafíos y subvalorar el tiempo y el costo requeridos para entregar, así como nuestra expectativa sesgada de los movimientos del mercado). Por lo tanto, añadimos un margen de contingencia adicional del 25%, aprendiendo de nuestros errores pasados.

Esto nos deja con el siguiente total: `(10 x $225k) x 1.25 = $2,812,500`

Finalmente, utilizando una tasa de conversión de `0.35` ADA por USD, formulamos una solicitud de presupuesto de **`₳8,035,714`**. Un [desglose completo de este presupuesto][detailed-scopes] está disponible a continuación.

> **NOTA** ¿Es `0.35 ADA/USD` una tasa de conversión justa?
>
> Aprendiendo de nuestra experiencia de financiación en 2025, reconocemos la importancia de tener en cuenta la volatilidad del mercado al planificar entregas a largo plazo.
>
> Al momento de escribir, el precio de ADA es aproximadamente `0.3 USD` por ADA. Proponemos una tasa de conversión de `0.35 ADA/USD`, que tiene en cuenta el mercado actual al tiempo que proporciona un margen razonable.
>
> Combinado con la contingencia reembolsable del 25%, este enfoque busca asegurar una entrega segura e ininterrumpida de los proyectos sin solicitar en exceso al tesoro.

## Administración del Presupuesto y Supervisión de Gobernanza

### Custodia Mediante Smart Contract

Los fondos se mantienen y liberan a través de los treasury-contracts de SundaeLabs (https://github.com/SundaeSwap-finance/treasury-contracts), un marco probado con dos validadores:

treasury.ak: Custodia todos los ADA retirados del tesoro de Cardano. Todo se bloquea aquí cuando la acción de gobernanza se promulga.
vendor.ak: Gestiona la liberación basada en hitos para HLabs. Calendario de pagos, fechas de liberación, condiciones de entrega.
Ambos contratos han sido auditados de forma independiente por TxPipe y MLabs y están en uso en producción en mainnet.

#### Comité de Supervisión Independiente

Un comité de supervisión independiente proporciona gobernanza de terceros:

Santiago Carmuega (TxPipe, Dolos)
Lucas Rosa (Aiken, Starstream, Midnight)
Chris Gianelloni (BlinkLabs, Dingo)

Los miembros del comité no tienen participación en HLabs. Co-firman los desembolsos, revisan los hitos y pueden detener el financiamiento si no estamos entregando.

#### Esquema de Permisos

Las acciones permitidas por el contrato de custodia son las siguientes:

Desembolso (liberación periódica): HLabs inicia + cualquier miembro del comité co-firma
Devolución anticipada (retorno de fondos no utilizados): HLabs + cualquier miembro del comité
Reorganización (ajuste del calendario de hitos): Solo HLabs
Financiación (configuración inicial del proveedor): Mayoría del comité
Suspensión de hito: Cualquier miembro del comité
Reanudación de hito: Mayoría del comité
Modificación del proyecto: HLabs + mayoría del comité
Las operaciones diarias requieren una firma del comité. Los cambios estructurales requieren al comité completo. Y cualquier miembro individual puede pausar si algo no parece correcto.

#### Política de Delegación

El contrato del tesoro establece la delegación automática como DRep abstencionista y sin delegación a SPOs para todos los fondos en custodia. Los fondos del tesoro no influyen en las votaciones de gobernanza ni en el staking.

#### Mecanismo de Devolución Automática

Los fondos que permanezcan en el contrato después de su vencimiento se devuelven automáticamente al tesoro de Cardano. Esto se ejecuta a nivel contractual. No puede ser anulado.

## Lista de verificación de constitucionalidad

En un esfuerzo por convencernos de la constitucionalidad de la propuesta, consideramos relevante incluir una lista de verificación de los puntos que cubrimos y, para cada uno, nuestra interpretación de la Constitución de Cardano.

#### Propósito

- [x] Esta propuesta es para trabajo destinado a mejorar la seguridad, la descentralización y la sostenibilidad a largo plazo de Cardano.

#### Artículo III.5: el proceso de gobernanza en cadena

- [x] Hemos presentado esta propuesta en un formato estandarizado y legible, que incluye una URL y un hash de todo el contenido documentado fuera de cadena. Creemos que nuestra justificación es detallada y suficiente. La propuesta contiene un título, un resumen, la razón de la propuesta y materiales de apoyo relevantes.

#### Artículo IV.1: propuesta de presupuestos

- [x] Esta propuesta se ajusta a las disposiciones de este artículo ya que está destinada a cubrir el mantenimiento y el desarrollo futuro de la Blockchain de Cardano.

- [x] Esta propuesta cubre un período de 12 meses (73 épocas) como recomienda esta disposición de la Constitución.

#### Artículo IV.3: Límite de Cambio Neto

- [x] Los presupuestos no necesitan ser evaluados en el contexto de un Límite de Cambio Neto, solo los retiros. Sin embargo, reconocemos que el establecimiento de un nuevo Límite de Cambio Neto probablemente será necesario para promulgar retiros correspondientes a este presupuesto. Reevaluaremos la situación a su debido tiempo y posiblemente dividiremos los retiros en múltiples si fuera necesario.

#### Alineación Estratégica con Cardano 2030

- [x] Esta propuesta apoya directamente el Marco Estratégico Cardano 2030, contribuyendo al KPI de "Clientes de nodo completo alternativos" (Pilar 1: Seguridad y Resiliencia) y las prioridades de Experiencia del Desarrollador (Pilar 2: Adopción y Utilidad).

- [x] Se han definido indicadores de adopción medibles para proporcionar visibilidad sobre las contribuciones a los KPIs a nivel de ecosistema (TVL, transacciones mensuales, MAU).

## Vista Detallada del Presupuesto

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!------------------------------------------ gerolamo ------------------------------------------>
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Gerolamo (nodo Cardano en TypeScript)

[repo](https://github.com/HarmonicLabs/gerolamo)

| 🎯 Objetivo Principal                |
| ---                                  |
| nodo de datos con mínima confianza para dApps |

Gerolamo es una implementación en TypeScript del nodo de Cardano diseñada para:
- **Compatibilidad con navegadores**: Servir como base para nodos que se ejecutan en navegadores
- **Extensibilidad**: Ser la base para nodos con propósitos específicos (nodos ligeros, nodos solo-UTxO, indexadores de cadena)

#### Cobertura Completa de Reglas del Libro Mayor

##### Objetivo

Implementar las reglas completas de validación del libro mayor para permitir que Gerolamo valide completamente bloques y transacciones de acuerdo con las especificaciones del protocolo Cardano.

##### Resultados Clave

- Gestión completa del estado del libro mayor utilizando LMDB (o IndexedDB para navegadores) para mejoras de rendimiento.
- Implementación de consenso (Praos) con selección de cadena y manejo de reversiones
- Base de datos volátil para gestionar bifurcaciones de cadena
- Validación de bloques y transacciones cubriendo todas las eras

##### Esfuerzo Estimado

2.5 FTEs

#### APIs del Nodo

##### Objetivo

Proporcionar APIs completas para desarrolladores de dApps y operadores de infraestructura para interactuar con la red de Cardano a través de Gerolamo.

##### Resultados Clave

- Endpoints RPC de UTxO para consultas eficientes de UTxO
- Soporte de socket local para protocolos node-to-client (compatibilidad con cardano-db-sync, cardano-cli)
- API de navegador para uso de dApps

##### Esfuerzo Estimado

2 FTEs

#### Mejoras de la Máquina Plutus

##### Objetivo

Mejorar continuamente el intérprete CEK de [plutus-machine](https://github.com/HarmonicLabs/plutus-machine) para mejor rendimiento y conformidad total con la especificación de Plutus.

##### Resultados Clave

- Optimizaciones de rendimiento para la evaluación de scripts
- Seguimiento de presupuesto y mejoras en la precisión del modelo de costos
- Soporte de sourcemaps para depuración

##### Esfuerzo Estimado

0.5 FTEs

### Gerolamo ━ Resumen

- total de recursos estimados: `5 FTEs`

#### Criterios de Preparación para Producción

Gerolamo se considerará listo para producción para despliegue como relay cuando cumpla los siguientes criterios objetivos:

| Criterio                 | Requisito                                                      | Método de Verificación  |
| :----------------------- | :------------------------------------------------------------- | :---------------------- |
| **Fiabilidad de sincronización** | Sincronización exitosa desde génesis hasta la punta en mainnet | Integración continua    |
| **Rendimiento de sincronización** | Sincronización inicial ≤48 horas en hardware estándar (4 CPU, 16GB RAM) | Suite de benchmarks |
| **Conectividad de pares** | Conexiones estables con ≥15 pares durante ≥24 horas           | Validación de red       |
| **Propagación de bloques** | Latencia de retransmisión de bloques dentro de 2x de la línea base del nodo Haskell | Benchmarks comparativos |
| **Manejo de reversiones** | Recuperación exitosa de reversiones de hasta k=2160 bloques    | Escenarios adversos     |

#### Propuesta de Valor vs. Otras Implementaciones de Nodo

| Dimensión            | Nodo Haskell                 | Amaru                                    | Gerolamo                       | Beneficio de Gerolamo                             |
| :------------------- | :------------------------- | :--------------------------------------- | :----------------------------- | :------------------------------------------------ |
| **Entorno de ejecución** | Entorno GHC              | Nativo (Rust)                            | Bun/Node.js/Navegador          | Se ejecuta donde sea que JavaScript funcione, incluyendo navegadores |
| **Soporte de navegador** | No                       | Soporte limitado planeado (WASM, finales 2026) | Sí (IndexedDB + WebWorkers) | Soporte de navegador listo para producción antes |
| **Acceso para desarrolladores** | Requiere experiencia en Haskell | Requiere experiencia en Rust       | TypeScript/JavaScript          | Mayor grupo de contribuidores (17M+ desarrolladores JS/TS) |
| **Extensibilidad**   | Específico de Cardano        | Ecosistema de crates de Rust             | Integración con ecosistema npm | Integración fluida con herramientas web/dApp      |
| **Casos de uso**     | Producción completa de bloques | Producción completa de bloques         | Relay, nodo de datos, nodo de navegador | Complementario; capacidad nativa de navegador JS/TS |

> [!NOTE]
>  Gerolamo está diseñado como una **implementación complementaria** para casos de uso de relay y nodo de datos, no como un reemplazo para nodos productores de bloques aún. La producción de bloques hasta ahora permanece en el nodo Haskell.
>
> Llegar a un punto donde el nodo pueda considerarse seriamente como relay, en cuanto a funcionalidad, debería acercarnos bastante a un punto donde también pueda usarse para producción de bloques.
>
> sin embargo, habilitar la producción de bloques en un entorno de mainnet incurriría en un aumento serio en los fondos que necesitaríamos solicitar
>
> solo para la auditoría de seguridad, los equipos de Amaru y BlinkLabs están solicitando 500k USD adicionales, lo cual creemos que es apropiado.
>
> adicionalmente, si fuéramos a incluir la producción de bloques entre los objetivos de este año, también necesitaríamos aumentar el esfuerzo estimado en *al menos* 1 FTE más.
>
> si las condiciones lo permiten el próximo año, la producción de bloques se considerará seriamente.
>
> dado el entorno actual, decidimos que sería mejor recortar esos esfuerzos para contener los costos.

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!------------------------------------------- pebble ------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Pebble (lenguaje de programación para smart contracts)

[repo](https://github.com/HarmonicLabs/pebble)

| 🎯 Objetivo Principal              |
| ---                                |
| lenguaje y herramientas listos para producción |

Pebble es un lenguaje funcional simple, pero sólido como una roca, con sesgo imperativo, que compila a UPLC (Untyped Plutus Core). Proporciona a los desarrolladores una sintaxis intuitiva mientras compila a código en cadena altamente optimizado.

#### Estabilidad del Compilador

##### Objetivo

Alcanzar estabilidad de compilador de nivel producción con generación de código optimizado.

##### Resultados Clave

- Sistema de tipos completo con inferencia de tipos total
- Generación de código UPLC optimizado con tamaños de script mínimos
- Reporte de errores completo con mensajes accionables
- Soporte para Plutus V4
- Documentación y tutoriales para la incorporación de nuevos desarrolladores

##### Esfuerzo Estimado

2 FTEs

#### Herramientas para Desarrolladores

##### Objetivo

Proporcionar una experiencia de desarrollo completa para desarrolladores de Pebble con integración de IDE, herramientas de depuración y soporte del sistema de compilación.

##### Resultados Clave

- Implementación del **Language Server Protocol (LSP)**:
  - Resaltado de sintaxis
  - Autocompletado
  - Ir a definición
  - Buscar referencias
  - Reporte de errores en línea
  - Documentación al pasar el cursor
- **Sourcemaps estables y confiables** para depuración de contratos compilados
- **Mejoras de CLI**:
  - Modos de compilación y vigilancia
  - REPL para desarrollo interactivo
- **Generación de blueprints** para metadatos de contratos

##### Esfuerzo Estimado

1.5 FTEs

### Pebble ━ Resumen

- total de recursos estimados: `3.5 FTEs`

#### Diferenciación respecto a Aiken

Pebble y Aiken sirven a diferentes perfiles de desarrolladores y son **complementarios** dentro del ecosistema de Cardano, no competitivos.

| Dimensión              | Aiken                            | Pebble                                 | Implicación                                           |
| :--------------------- | :------------------------------- | :------------------------------------- | :---------------------------------------------------- |
| **Paradigma**          | Funcional primero (inspirado en Rust) | Imperativo primero (inspirado en TypeScript) | Diferentes modelos mentales para diferentes desarrolladores |
| **Audiencia objetivo** | Desarrolladores cómodos con PF   | Desarrolladores Web2/EVM               | Amplía el grupo total de desarrolladores alcanzables   |
| **Familiaridad de sintaxis** | Rust, Gleam                | TypeScript, JavaScript, Solidity       | Menor barrera para los 17M+ desarrolladores JS/TS a nivel global |
| **Curva de aprendizaje** | Requiere fundamentos de PF     | Patrones imperativos familiares        | Incorporación más rápida para la mayoría de desarrolladores |

##### Por qué ambos importan

Cardano necesita múltiples vías de acceso para desarrolladores:
- Desarrolladores con experiencia en Rust/Haskell/PF gravitan hacia Aiken
- Desarrolladores con experiencia en JS/TS/Solidity encontrarán Pebble más accesible
- Ambos compilan a UPLC optimizado; la elección es sobre preferencia del desarrollador, no rendimiento en tiempo de ejecución

Al financiar Pebble, el Tesoro amplía el embudo de desarrolladores de Cardano sin fragmentarlo.

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!--------------------------------------- hf maintenance --------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Mantenimiento de hard fork

| 🎯 Objetivo Principal          |
| ---                            |
| garantizar estabilidad del ecosistema |

#### Próximo Hard Fork Intra-Era

##### Objetivo

Asegurar que todas las bibliotecas TypeScript de HLabs estén actualizadas y sean totalmente compatibles con el próximo hard fork, incluyendo los cambios de Plutus V4 y los nuevos parámetros del protocolo.

##### Resultados Clave

Mantenimiento de los repositorios afectados para soportar nuevas características del protocolo:

- **[cardano-ledger-ts](https://github.com/HarmonicLabs/cardano-ledger-ts)**: Colección de funciones y clases que definen las estructuras de datos del libro mayor de Cardano
- **[ouroboros-miniprotocols-ts](https://github.com/HarmonicLabs/ouroboros-miniprotocols-ts)**: Implementación en TypeScript del protocolo de red Ouroboros
- **[plutus-machine](https://github.com/HarmonicLabs/plutus-machine)**: Implementación de la máquina CEK para evaluación de UPLC
- **[uplc](https://github.com/HarmonicLabs/uplc)**: Representación en TypeScript/JavaScript de UPLC

##### Esfuerzo Estimado

1.5 FTE

### Mantenimiento de Hard Fork ━ Resumen

- total de recursos estimados: `1.5 FTE`

---

# Retrospectiva 2025

## Descripción General

En 2025, Harmonic Laboratories recibió su primera financiación del Tesoro de Cardano a través de los Intersect Treasury Contracts para el proyecto **Gerolamo** (EC-0014-25). El proyecto tenía como objetivo crear un nodo de datos de Cardano que pueda ejecutarse en el navegador, implementado completamente en TypeScript.

A pesar de que se suponía que la financiación cubriría 73 épocas, el despliegue del contrato en cadena fue efectivo recién a mediados de agosto, cubriendo por lo tanto un período desde el **12 de agosto de 2025 hasta el 30 de marzo de 2026**.

La financiación total para el proyecto fue de **₳578,571 ADA**; debido a diversas fallas de comunicación con la parte administradora durante la fase de presentación de la propuesta, la tasa de conversión fue de aproximadamente `0.7 ADA/USD`; la fuerte caída en el precio del activo con el que se nos paga desde entonces, actualmente por debajo de `0.3 ADA/USD`, causó que la valoración del proyecto fuera significativamente inferior a lo justo.

Harmonic Laboratories se enorgullece enormemente de decir que seguimos cumpliendo nuestra palabra a pesar de las condiciones extremadamente adversas.

## Comparación de Hoja de Ruta

| Planificado | Estado | Notas |
| :--- | :---: | :--- |
| Mini-protocolos Ouroboros | ✅ | Handshake, ChainSync, BlockFetch funcionando |
| Sincronización de cadena multi-era | ✅ | Eras entre Shelley y Conway soportadas |
| Análisis de bloques/encabezados | ✅ | Usando `@harmoniclabs/cardano-ledger-ts` |
| Validación de encabezados | ✅ | Verificación VRF y comprobación de tipo de era |
| Envío de transacciones | ✅ | Endpoint `/txsubmit` retransmitiendo a pares |
| Validación de bloques | ✅ | Aplicación de bloques con actualizaciones del estado del libro mayor |
| Manejo de reversiones | ✅ | Soporte de reversión de cadena implementado |
| Almacenamiento completo | ✅ | Fragmentos volátiles + inmutables, concurrencia WAL |
| API HTTP de Bloques | ✅ | Endpoint `/block/{slot}` sirviendo CBOR hex |
| Gestión de pares P2P | 🟡 | El nodo ya es capaz de manejar múltiples pares, la selección dinámica de pares es lo siguiente |
| Gestión de mempool | ✅ | Se implementó un mempool con soporte multi-hilo |
| Integración con Mithril | 🟡 | En progreso - el soporte inicial ya está integrado y seguimos mejorándolo |
| Compatibilidad con navegadores | 🟡 | En progreso - se han tomado varias decisiones de diseño para facilitar la integración de un nodo compatible con navegadores |

## Logros Clave

### Validación y Aplicación de Bloques
Pipeline completo de validación de bloques implementado, incluyendo verificación de encabezados y aplicación del cuerpo del bloque al estado del libro mayor. El nodo ahora valida los bloques entrantes contra las reglas del protocolo antes de aplicarlos al estado local de la cadena, asegurando la integridad de los datos.

### Validación de Encabezados con Verificación VRF
Lógica completa de validación de encabezados con verificación criptográfica VRF (Función Aleatoria Verificable). Esto asegura que los productores de bloques sean correctamente elegidos de acuerdo con su stake y que los encabezados sean auténticos.

### Manejo de Reversiones
Soporte robusto de reversión de cadena que permite al nodo manejar reorganizaciones de cadena de manera elegante. Cuando la red experimenta una bifurcación, Gerolamo puede revertir hasta un ancestro común y re-sincronizar a lo largo de la cadena ganadora.

### Arquitectura de Almacenamiento
Sistema de almacenamiento de doble capa con fragmentos volátiles e inmutables:
- **Almacenamiento volátil**: Bloques recientes mantenidos en almacenamiento de acceso rápido para posibles reversiones
- **Fragmentos inmutables**: Bloques más antiguos y finalizados archivados en fragmentos comprimidos
- **Concurrencia WAL**: Write-Ahead Logging para acceso concurrente seguro a la base de datos

### APIs HTTP
Endpoints RESTful para integraciones externas:
- `/block/{slot|hash}` - Recuperar bloques por número de slot o hash (CBOR hex)
- `/utxo/{txhash:index}` - Consultar UTxOs específicos
- `/txsubmit` - Enviar transacciones a la red

### Soporte Multi-Era
Soporte completo de análisis y validación para todas las eras de Cardano desde Shelley hasta Conway, utilizando `@harmoniclabs/cardano-ledger-ts` para el manejo de bloques y transacciones con seguridad de tipos.

### Interfaz de Terminal y Registro
TUI interactiva que muestra el progreso de sincronización, conexiones de pares y estado del nodo. Registro estructurado en JSONL con niveles configurables (debug/info/warn/error) para monitoreo en producción.

## Desafíos y Aprendizajes

- **Compatibilidad con Navegadores**: Asegurar que el nodo pueda ejecutarse en entornos de navegador requirió una consideración cuidadosa de varios backends de almacenamiento abstraídos y la arquitectura de hilos de trabajo.

- **Soporte Multi-Era**: Soportar todas las eras de Cardano desde Shelley hasta Conway añadió una complejidad significativa pero es esencial para una implementación completa del nodo.

- **Ritmo de Hitos**: El calendario agresivo de hitos requirió sprints de desarrollo intensos, particularmente evidente en los commits de enero de 2026 preparando para el cierre.

- **Devaluación de la Financiación**: Debido a la fuerte caída en el precio de ADA desde ~`0.7 ADA/USD` al momento de la presentación de la propuesta hasta ~`0.3 ADA/USD` actualmente, la financiación efectiva recibida es menos de la mitad del valor en USD originalmente anticipado. A pesar de esto, continuamos entregando todos los compromisos.

**Treasury Contract**: [EC-0014-25](https://treasury.sundae.fi/instances/9e65e4ed7d6fd86fc4827d2b45da6d2c601fb920e8bfd794b8ecc619/project/EC-0014-25)
