# Dingo: un Nodo Productor de Bloques de Grado Productivo en Go, por Blink Labs

## 1. Resumen Ejecutivo

Blink Labs solicita 6.900.000 ADA del Tesoro de Cardano para financiar
doce meses de ingeniería a tiempo completo en
[Dingo](https://github.com/blinklabs-io/dingo), nuestro nodo de Cardano
desarrollado en Go. Dingo se encuentra en desarrollo activo, y precisamente
ese es el propósito de esta propuesta. No obstante, se trata de un proyecto
con avances sustanciales: más de 1.290 PRs (sin incluir dependencias)
integrados durante el último año, conformidad del 100% en Plutus V1/V2/V3
frente al conjunto de pruebas de Plutus, 314 pruebas de conformidad
aprobadas, criptografía VRF/KES, ChainSync, mempool y soporte para
transacciones de gobernanza. Este financiamiento permitirá llevar a Dingo
a un estado de preparación para la producción de bloques en mainnet:
completar el consenso Ouroboros Praos, incorporar soporte para el hard fork
Dijkstra, implementar CIP-0164 Linear Leios en colaboración con IO
Engineering, realizar una auditoría de seguridad integral y ejecutar el
endurecimiento operativo necesario para garantizar la fiabilidad del nodo
a escala.

---

## 2. Motivación: Quiénes Somos

### Blink Labs

Somos una empresa de ingeniería especializada exclusivamente en software
blockchain integrado con Cardano. Desarrollamos en Go porque es el
lenguaje idóneo para sistemas de red de alto rendimiento y porque Cardano
se beneficia de contar con infraestructura central que millones de
desarrolladores pueden efectivamente leer y utilizar. Nuestro equipo
incluye un ingeniero de documentación a tiempo parcial y seis
colaboradores remunerados de código abierto a tiempo parcial que
colaboran en el mantenimiento y la expansión del ecosistema.

Llevamos construyendo sobre Cardano desde 2021. A continuación, nuestros
proyectos entregados:

| Proyecto | Descripción | Madurez |
|----------|-------------|---------|
| [Dingo](https://github.com/blinklabs-io/dingo) | Nuestro nodo Cardano en Go: ChainSync, primitivas de forja de bloques VRF/KES, evaluación Plutus, mempool, gobernanza, UTxO RPC, Mini-Blockfrost y APIs Mesh (Rosetta) | Aún no preparado para mainnet, pero más de 300 PRs integrados y 314/314 pruebas de conformidad |
| [gOuroboros](https://github.com/blinklabs-io/gouroboros) | Biblioteca de mini-protocolos Ouroboros con soporte completo de eras desde Byron hasta Conway | Más de 2.200 pruebas, utilizado por proyectos derivados |
| [Plutigo](https://github.com/blinklabs-io/plutigo) | Nuestro evaluador de scripts Plutus: V1, V2, V3 con conformidad del 100% frente al conjunto de pruebas de Plutus | Integrado en Dingo |
| [ouroboros-mock](https://github.com/blinklabs-io/ouroboros-mock) | Marco de pruebas de conformidad con 314 vectores de prueba de Amaru y simulación de estado del ledger | Infraestructura compartida |
| [Adder](https://github.com/blinklabs-io/adder) | Pipeline de indexación de cadena y notificación de eventos con salidas configurables | En producción |
| [nview](https://github.com/blinklabs-io/nview) | Monitoreo de nodos basado en terminal | Entregado |
| [TxSubmit API](https://github.com/blinklabs-io/tx-submit-api) | Servicio de envío de transacciones | En producción, basado en Docker |
| Imágenes Docker | Contenedores para nodo Cardano y herramientas asociadas | Ampliamente adoptados por SPOs |

Además de nuestros proyectos propios, co-mantenemos diversas bibliotecas
Go dentro del ecosistema Cardano, incluyendo Apollo, Ogmigo, Kugo y el
SDK Go de UTxO RPC.

Nuestro financiamiento previo en Cardano proviene de Project Catalyst (que
financió el desarrollo de gOuroboros y el trabajo inicial de Dingo) y de
autofinanciamiento. Somos miembros de PRAGMA; sin embargo, no hemos
recibido fondos de la propuesta de tesorería de Amaru ni de ningún otro
retiro de tesorería, a pesar de nuestra membresía. Esta propuesta se
presenta para su evaluación en función de sus propios méritos.

### Personal Clave

- Chris Gianelloni, Arquitecto Principal. Diseñó y lidera el desarrollo
  de Dingo, gOuroboros y la infraestructura Go en su conjunto.
  Responsable de las decisiones de arquitectura, la implementación de
  protocolos y la dirección técnica.

- Christina Gianelloni, Directora de Operaciones. Responsable de
  marketing, divulgación comunitaria, relacionamiento con DReps, sesiones de
  preguntas y respuestas (AMA), redes sociales y comunicaciones de
  gobernanza. Su gestión permite que el equipo de ingeniería mantenga su
  enfoque en el desarrollo.

---

## 3. Motivación: Por Qué Dingo

### La Diversidad de Nodos Es Resiliencia de Red

Cardano opera actualmente con una única implementación de nodo para la
producción de bloques. Cada productor de bloques en la red ejecuta el
mismo código. Un defecto crítico en un solo punto —ya sea un error de
consenso, una fuga de memoria bajo carga o una vulnerabilidad en
producción— afecta a todos simultáneamente. No existe un respaldo
alternativo.

La diversidad de nodos transforma esta situación. Amaru está desarrollando
una implementación en Rust, y Dingo aporta Go. Múltiples implementaciones
independientes significan que un error en una de ellas no compromete toda
la red. Ethereum aprendió esta lección de manera empírica: su arquitectura
multi-cliente les ha protegido en repetidas ocasiones cuando clientes
individuales presentaron errores que, de otro modo, habrían provocado
interrupciones generalizadas.

### Accesibilidad del Ecosistema Go

La infraestructura central de Cardano está escrita en Haskell. Go cuenta
con más de 5 millones de desarrolladores activos y ocupa el séptimo lugar
en el índice TIOBE. Es el lenguaje que la industria ya eligió para nodos
blockchain: Geth (Ethereum), btcd (Bitcoin), CometBFT (más de 50 cadenas
Cosmos), AvalancheGo, Algorand y Filecoin. Un nodo Cardano en Go no
representa una novedad; es una necesidad largamente pendiente.

Go es también el lenguaje predilecto de los principales proveedores de
infraestructura cripto. Coinbase desarrolló su estándar de integración
blockchain Rosetta/Mesh íntegramente en Go. Tanto Binance como Kraken
emplean Go como lenguaje central para su infraestructura de negociación.
La mayoría de las cadenas EVM distribuyen clientes en Go (derivados de
Geth), lo que significa que los exchanges y proveedores de infraestructura
que integran múltiples cadenas ya poseen una sólida experiencia en Go. Un
nodo Cardano en Go reduce la fricción de integración y simplifica la
incorporación de las empresas que Cardano necesita atraer.

Dingo abre las interioridades del nodo Cardano a esos más de 5 millones de
desarrolladores. Ingenieros en Google, Cloudflare o Docker pueden leer
este código, auditarlo y contribuir sin necesidad de aprender un nuevo
lenguaje. No se trata de reemplazar Haskell, sino de hacer Cardano
accesible a los desarrolladores que efectivamente existen en la industria.

### Trayectoria de Entrega y Eficiencia en Costos

Contamos con una trayectoria documentada. En Dingo, gOuroboros y Plutigo,
hemos integrado 1.290 PRs sin dependencias en los últimos doce meses y 593
en el último trimestre, con una tendencia acelerada. Con 2 a 3 ingenieros
a tiempo parcial. Esto equivale a aproximadamente 36 PRs por persona por
mes, con más de 304.000 líneas de código agregadas.

Estas cifras son retrospectivas, no compromisos a futuro. El trabajo
transiciona de la implementación de protocolos al endurecimiento del
consenso, que es un esfuerzo cualitativamente diferente. Sin embargo, la
cultura de ingeniería que produjo estos resultados es la misma que
respaldará esta propuesta.

#### Disciplina de Desarrollo

Producimos PRs de tamaño reducido, aproximadamente 236 líneas cada uno.
Deliberadamente. PRs más pequeños implican revisiones más ágiles, menor
riesgo en la integración y ciclos de retroalimentación más cortos. El
resultado acumulado: 304.000 líneas de código nuevo en doce meses.

#### Eficiencia en Costos

El costo de personal asciende a $1.250.000 USD para cinco empleados a
tiempo completo ($250.000 por persona). El resto corresponde a una
auditoría única ($500.000), infraestructura en la nube ($50.000) y contingencia del 15%.
Otras implementaciones de nodos financiadas utilizaron un precio de
$0,50/ADA durante el ciclo 2025. A ese mismo precio, nuestro total de
$2.070.000 equivaldría a aproximadamente 4.140.000 ADA. Buscamos
presentar una solicitud prudente y plenamente justificable.

### Escalabilidad Mediante Leios

CIP-0164 Linear Leios representa el próximo salto significativo en el
rendimiento de Cardano: un incremento de 30 a 50 veces mediante una
arquitectura de dos tipos de bloque (Endorser Blocks y Ranking Blocks)
con votación basada en sorteo y certificados. Ya estamos colaborando
directamente con IO Engineering en este desarrollo, y el modelo de
concurrencia de Go (goroutines y canales) está prácticamente diseñado
para el tipo de concurrencia de pipeline que Leios requiere.
Desarrollarlo en Go en paralelo con la referencia en Haskell fortalece
además la especificación: las ambigüedades se identifican con mayor
rapidez cuando dos equipos implementan el mismo protocolo en dos lenguajes
distintos.

### Sostenibilidad a Través del Código Abierto

Todo lo que desarrollamos se publica bajo licencia Apache 2.0. Siempre
ha sido así, y siempre lo será. Este trabajo constituye un bien público
permanente. No desaparece si Blink Labs deja de existir.

### Lo Que el Ecosistema Pierde Sin Financiamiento

Sin financiamiento, Dingo continúa avanzando con los recursos limitados
que podamos destinar. En términos concretos:

- La producción de bloques se limita exclusivamente a devnet local. El
  trabajo de consenso para redes activas no se realiza.
- No existe una propuesta para operadores de pools (SPOs). Los operadores
  de pools no podrán ejecutarlo como productor de bloques. La diversidad
  de nodos permanece como un concepto teórico, no una realidad operativa.
- El soporte para Dijkstra se implementará eventualmente, pero en plazos
  significativamente más extensos.
- Leios en Go se restringe exclusivamente al lado del cliente. Los
  beneficios de fortalecimiento de la especificación que aporta una
  segunda implementación completa no se materializan.
- No se realiza auditoría de seguridad. Esto requiere una inversión
  considerable.

La comunidad de Cardano ya ha invertido en esta plataforma tecnológica
a través de Catalyst y de años de nuestro propio tiempo y recursos
financieros. Sin este financiamiento, dicha inversión no alcanzará su
máximo potencial.

---

## 4. Justificación: Resumen Ejecutivo de Costos

Se solicita un único retiro del tesoro para cubrir doce meses de
desarrollo. Todos los montos se expresan en USD con conversión a ADA al
momento de la acción de gobernanza, más un margen de contingencia para la
volatilidad del precio.

| Categoría | Costo Estimado (USD) |
|-----------|---------------------:|
| Ingeniería (4 ingenieros Go a tiempo completo × 12 meses) | $1.000.000 |
| Operaciones (1 persona a tiempo completo × 12 meses: infraestructura, Dirección de Operaciones, marketing y divulgación) | $250.000 |
| Auditoría de seguridad (firma de primer nivel) | $500.000 |
| Hospedaje de infraestructura y CI/CD | $50.000 |
| Subtotal | $1.800.000 |
| Contingencia (~15% por incertidumbre de alcance) | $270.000 |
| Total | $2.070.000 |

Monto solicitado: 6.900.000 ADA (a $0,30/ADA)

### Notas Sobre el Presupuesto

- La ingeniería constituye el costo principal: cuatro ingenieros Go a
  tiempo completo durante doce meses. Los $250.000 por persona incluyen
  la totalidad de conceptos: salarios, prestaciones y equipo. Son
  empleados de Blink Labs, no contratistas externos. Será necesario
  contratar tres desarrolladores Go para alcanzar capacidad plena, y es
  posible que promovamos desde nuestro equipo actual de colaboradores
  remunerados de código abierto.

- Operaciones se distribuye entre un ingeniero de infraestructura (CI/CD,
  operación de nodos en testnet y mainnet, despliegue y monitoreo) y la
  Directora de Operaciones (marketing, divulgación comunitaria,
  comunicaciones de gobernanza, relacionamiento con DReps y redes sociales).
  La partida de $50.000 para infraestructura corresponde exclusivamente a
  servicios de infraestructura en la nube; el esfuerzo humano se contempla en la línea de
  operaciones.

- La auditoría de seguridad se presupuesta en aproximadamente $500.000
  para una revisión exhaustiva por parte de una firma de primer nivel
  (Trail of Bits, NCC Group o equivalente). Antes de recomendar que
  alguien ejecute Dingo como productor de bloques, queremos que
  profesionales especializados intenten vulnerarlo.

- Base de precio del ADA. Utilizamos $0,30/ADA porque es
  aproximadamente el precio actual del mercado. Otras implementaciones
  financiadas por el tesoro utilizaron $0,50 durante el ciclo 2025. A ese
  precio, nuestros $2.070.000 equivaldrían a aproximadamente 4.140.000
  ADA. Preferimos establecer un precio honesto y permitir que las cifras
  hablen por sí mismas.

- La contingencia es de aproximadamente el 15%. La auditoría podría
  revelar hallazgos que requieran corrección. Dado que hemos fijado el
  precio cercano al mercado en lugar de $0,50, la volatilidad del precio
  representa una preocupación menor. Nuestra estrategia de cobertura
  consiste en la conversión a stablecoins o moneda fiduciaria al momento
  de la recepción.

- Retiro único. El monto total en un solo retiro del tesoro, con hitos
  sujetos a cumplimiento mediante contrato inteligente de custodia y
  revisión del comité de supervisión (véase la Sección 5).

### Estimación de Esfuerzo y Capacidad de Reserva

Consideramos fundamental ser transparentes respecto a cómo el trabajo
estimado se corresponde con la capacidad financiada. La siguiente tabla
presenta nuestra evaluación de ingeniería en meses-ingeniero:

| Categoría | Esfuerzo Estimado |
|-----------|------------------:|
| Producción de bloques en mainnet | 6 |
| Hard fork Dijkstra | 5 |
| CIP-0164 Linear Leios | 6 |
| Endurecimiento operativo | 6 |
| Paridad de funcionalidades | 8 |
| Integración con el ecosistema | 6 |
| **Total de trabajo estimado** | **37** |
| **Capacidad del equipo (4 ingenieros × 12 meses)** | **48** |
| **Reserva** | **11 (25%)** |

Nuestra velocidad medida durante el último año es de aproximadamente 36
PRs sin dependencias por persona por mes en Dingo, gOuroboros y Plutigo,
considerablemente superior a la demostrada por otros equipos de nodos
Cardano. Hemos ajustado nuestras estimaciones para contemplar la
transición de la implementación de protocolos al trabajo más complejo de
endurecimiento del consenso y preparación operativa.

#### Justificación de la Reserva

Las especificaciones no están finalizadas, la auditoría podría revelar
hallazgos significativos, y Leios es un objetivo en constante evolución.
Si las circunstancias son favorables, la capacidad adicional se destinará
a elementos priorizados por la comunidad. Los ADA no utilizados retornan
automáticamente al tesoro al vencimiento del contrato. Esto se garantiza
a nivel contractual, no mediante una promesa.

---

## 5. Justificación: Administración del Presupuesto

### Custodia Mediante Contrato Inteligente

Los fondos se custodian y liberan a través de los
[SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts),
un marco probado con dos validadores:

- treasury.ak: Custodia la totalidad de los ADA retirados del tesoro de
  Cardano. Todos los fondos se bloquean aquí cuando la acción de
  gobernanza entra en vigor.
- vendor.ak: Gestiona la liberación basada en hitos para Blink Labs.
  Calendario de pagos, fechas de liberación y condiciones de entrega.

Ambos contratos han sido auditados de forma independiente por TxPipe y
MLabs, y se encuentran en uso productivo en mainnet.

### Blink Labs como Proveedor Único

Blink Labs es el único proveedor. Todo el trabajo es realizado por nuestro
equipo. No se subcontrata. Si algún entregable no se cumple, la
responsabilidad es inequívoca.

### Comité de Supervisión Independiente

Un comité de supervisión independiente proporciona gobernanza por parte de
terceros:

- **Pi Lanningham** (SundaeSwap)
- **Santiago Carmuega** (TxPipe)
- **Lucas Rosa** (Aiken, Midnight)

Los miembros del comité no tienen participación en Blink Labs. Co-firman
los desembolsos, revisan los hitos y tienen la facultad de suspender el
financiamiento en caso de incumplimiento.

### Esquema de Permisos

Utilizamos un modelo de permisos de mínima fricción: sin cuellos de
botella, pero con supervisión efectiva:

| Acción | Firmas Requeridas |
|--------|-------------------|
| Desembolso (liberación periódica) | Blink Labs inicia + cualquier miembro del comité co-firma |
| Devolución anticipada (retorno de fondos no utilizados) | Blink Labs + cualquier miembro del comité |
| Reorganización (ajuste del calendario de hitos) | Solo Blink Labs |
| Configuración inicial del proveedor | Mayoría del comité |
| Suspensión de hito | Cualquier miembro individual del comité |
| Reanudación de hito | Mayoría del comité |
| Modificación del proyecto | Blink Labs + mayoría del comité |

Las operaciones cotidianas requieren una firma del comité. Los cambios
estructurales requieren la aprobación del comité en pleno. Cualquier
miembro individual puede activar una suspensión si detecta alguna
irregularidad.

### Política de Delegación

El contrato del tesoro establece la delegación automática como DRep
abstencionista y prohíbe la delegación a SPOs para todos los fondos en
custodia. Los fondos del tesoro no influyen en las votaciones de
gobernanza ni en el staking.

### Mecanismo de Devolución Automática

Los fondos que permanezcan en el contrato después de su vencimiento se
devuelven automáticamente al tesoro de Cardano. Esto se ejecuta a nivel
contractual y no puede ser anulado.

### Liberaciones Periódicas Fijas

Los fondos se liberan según un calendario fijo establecido en el contrato
del proveedor, sujeto a la co-firma del comité. Esto garantiza un flujo
de caja predecible para nuestro equipo y capacidad de suspensión para el
comité. El calendario se alinea con los hitos trimestrales detallados en
la Sección 8.

---

## 6. Justificación: Informes de Rendición de Cuentas

### Actualizaciones Mensuales

Al cierre de cada mes, publicamos una actualización de estado:

- Entregables completados
- PRs clave, funcionalidades e hitos relevantes
- Riesgos o impedimentos identificados
- Plan para el período siguiente

Las actualizaciones se publican en el
[repositorio treasury-proposal](https://github.com/blinklabs-io/treasury-proposal)
y en los canales comunitarios.

### Informes Trimestrales Detallados

Cada trimestre, se elabora un informe completo:

- Avance respecto a cada hito
- Resumen financiero: fondos recibidos, ejecutados por categoría y
  remanentes
- Análisis de variaciones para desviaciones presupuestarias
- Registro actualizado de riesgos
- Plan para el trimestre siguiente

Los informes trimestrales coinciden con las solicitudes de desembolso,
proporcionando al comité la información necesaria para autorizar las
liberaciones.

### Diario Público de Transacciones

Cada transacción en cadena (desembolsos, solicitudes de liberación, devoluciones,
reorganizaciones) se registra en un
[diario público de transacciones](https://github.com/blinklabs-io/treasury-proposal/tree/main/journal).
Hash de la transacción, tipo de acción, monto, firmantes, justificación y
hash de metadatos en cadena. Estándar de metadatos de SundaeSwap.
Cualquier persona puede verificarlo contra la cadena.

### Sesiones de Código en Vivo y Demostraciones

Realizamos sesiones periódicas de programación en vivo y demostraciones
para que la comunidad pueda observar directamente el avance del trabajo:
desarrollo activo, decisiones arquitectónicas y capacidades de Dingo a
medida que se construyen. Se anuncian en X/Twitter y en el Foro de
Cardano, y se graban para consulta posterior.

---

## 7. Justificación: Lista de Verificación de Constitucionalidad

Esta sección evalúa la propuesta frente a la Constitución de Cardano
(v2.4), siguiendo el
[formato PRAGMA mnemos](https://github.com/pragma-org/mnemos).

### Propósito

Esta propuesta solicita un retiro del tesoro para financiar el desarrollo
de Dingo hasta alcanzar preparación para producción: un segundo nodo
completo de Cardano capaz de brindar servicio de datos y producción de
bloques, con soporte para Dijkstra e implementación de Leios.

### Artículo III, Sección 5: Acciones de Gobernanza en Cadena

> *Las acciones de gobernanza deberán seguir un formato estandarizado y
> legible, incluyendo una URL y hash de cualquier contenido fuera de
> cadena.*

Evaluación: CONFORME.

Metadatos CIP-108. La acción en cadena referencia metadatos fuera de
cadena mediante URL (fijada a hash de commit en GitHub, espejo IPFS vía
Blockfrost) con hash blake2b-256. Autocontenido, legible y conforme con
CIP-108.

### Artículo IV, Sección 1: Presupuesto para el Ecosistema Blockchain de Cardano

> *Se adoptará un presupuesto para el ecosistema blockchain de Cardano de
> manera anual mediante una acción de gobernanza en cadena.*

Evaluación: CONFORME.

Duración de doce meses (~73 épocas), alineado con el ciclo anual.
Presupuesto completamente especificado: ingeniería, auditoría,
infraestructura y contingencia.

### Artículo IV, Sección 2: Administración de Fondos

> *Los presupuestos del ecosistema blockchain de Cardano serán
> administrados por uno o más administradores de presupuesto seleccionados
> mediante un proceso transparente.*

Evaluación: CONFORME.

Contratos inteligentes SundaeSwap auditados con un comité de supervisión
independiente: Pi Lanningham (SundaeSwap), Santiago Carmuega (TxPipe) y
Lucas Rosa (Aiken, Midnight). Los miembros del comité no son partes
interesadas de Blink Labs. Los permisos, el calendario de desembolsos y
la supervisión están completamente especificados. Se incluye la facultad
de suspensión de emergencia y autoridad para resolución de controversias.

### Artículo IV, Sección 3: Límite de Cambio Neto

> *El Límite de Cambio Neto deberá ser observado por todos los retiros del
> tesoro durante el período presupuestario aplicable.*

Evaluación: CONFORME.

No contraviene el Límite de Cambio Neto (NCL) vigente al momento de la
presentación. Operaremos dentro del NCL que se encuentre en efecto.

En caso de que no exista un NCL cuando esta acción sea evaluada,
sugerimos: el retiro no deberá exceder 6.900.000 ADA, evaluado por
sus méritos en relación con el saldo del tesoro y otras solicitudes.
Esto constituye una orientación, no un sustituto de un NCL debidamente
promulgado.

### Artículo IV, Sección 4: Auditor

> *Deberá ser posible una auditoría independiente de todas las
> transacciones financiadas con recursos del tesoro de Cardano.*

Evaluación: CONFORME.

Diario público de transacciones con trazabilidad completa: hashes,
montos, firmantes y justificaciones. Los contratos SundaeSwap garantizan
los flujos de fondos en cadena. Cualquier persona puede verificar.
Se publican estados financieros trimestrales con detalle por categoría.

### Salvaguarda TREASURY-04a

> *Los retiros del tesoro para propuestas presupuestarias requieren que
> más del 50% del stake de votación activo de DReps vote a favor.*

Evaluación: RECONOCIDA.

Requiere más del 50% del stake de votación activo de DReps. Estamos
realizando actividades de divulgación, participación comunitaria y
sesiones de preguntas y respuestas (AMA) para que los delegados dispongan
de información completa sobre lo que estamos desarrollando, su costo y
los mecanismos de rendición de cuentas.

---

## 8. Alcance del Trabajo

Doce meses, cuatro trimestres, entregables concretos vinculados a los
hitos del contrato del proveedor. Todo el trabajo se realiza sobre las
bases de código existentes:
[Dingo](https://github.com/blinklabs-io/dingo),
[gOuroboros](https://github.com/blinklabs-io/gouroboros),
[Plutigo](https://github.com/blinklabs-io/plutigo) y
[ouroboros-mock](https://github.com/blinklabs-io/ouroboros-mock).
Licencia Apache 2.0.

#### Punto de Partida

Dingo actualmente sincroniza desde el génesis a través de todas las eras
(Byron a Conway), cuenta con primitivas de forja de bloques VRF/KES,
aprueba 314 pruebas de conformidad de Amaru (mediante el marco
ouroboros-mock), evalúa Plutus V1/V2/V3 con conformidad del 100% frente
al conjunto de pruebas de Plutus, gestiona mempool y transacciones de
gobernanza, soporta redes P2P y opera sobre múltiples backends de
almacenamiento (Badger para bloques, SQLite para metadatos, en memoria
para pruebas). Lo que aún no puede hacer: producir bloques en un entorno
de consenso activo. Ese es el objetivo del segundo trimestre.

### T2: Producción de Bloques en Testnet y Prototipo de Leios

#### Objetivo

Completar el consenso Ouroboros Praos lo suficiente para que Dingo
produzca bloques en una red de pruebas, e iniciar el prototipo de Leios.
Este es el trimestre de mayor complejidad, dado que concentra los retos
técnicos más exigentes del ciclo.

#### Entregables

- Consenso Ouroboros Praos completo: transiciones de época, verificación
  de elección de líder de slot, selección de cadena y los comportamientos
  restantes necesarios para que Dingo produzca y valide bloques como
  participante pleno.
- Combinador de hard forks: negociación de versión de protocolo y
  transición de eras para que Dingo gestione bifurcaciones sin necesidad
  de reinicio.
- Bootstrap de génesis: el mecanismo Ouroboros Genesis para nodos que
  se incorporan desde cero, incluyendo selección de pares y validación
  de cadena durante la sincronización inicial.
- ChainSync estable desde el génesis hasta la punta en preview y
  preprod. Manejo adecuado de interrupciones, desconexiones y
  reorganizaciones.
- Prototipo de CIP-0164 Linear Leios, desarrollado en colaboración con
  IO Engineering. Arquitectura de dos tipos de bloque (Endorser Blocks
  y Ranking Blocks) con votación basada en sorteo y certificados para
  un incremento de rendimiento de 30 a 50 veces. Nuevos tipos de bloque,
  serialización, validación de votos, temporización del pipeline y
  mini-protocolos para la difusión de EBs y votos. Seguimos la
  especificación y retroalimentamos las ambigüedades al equipo de
  investigación. En eso radica gran parte del valor de una segunda
  implementación.
- Ampliación de pruebas de conformidad más allá de los 314 vectores
  actuales para cubrir casos límite de consenso y transiciones de época.

### T3: Endurecimiento Operativo y Escalabilidad de Almacenamiento

#### Objetivo

Fortalecer a Dingo para estabilidad en operación prolongada y abordar
los riesgos conocidos de almacenamiento a volúmenes de datos de mainnet.

#### Entregables

- Endurecimiento operativo: perfilado bajo cargas de trabajo realistas.
  Identificación de fugas de memoria, optimización de rutas críticas y
  establecimiento de líneas base de rendimiento.
- Escalabilidad de almacenamiento: nuestros backends actuales (Badger,
  SQLite) no han sido sometidos a pruebas a escala de mainnet (~100M
  UTxOs, ~500 GB de cadena). Benchmarking, identificación de cuellos de
  botella, optimizaciones o migraciones según sea necesario.
- Gestión del conjunto UTxO a cardinalidad de mainnet: latencia de
  consulta y huella de memoria aceptables.
- Pruebas a escala de mainnet: Dingo operando contra ~100M UTxOs, ~500
  GB de cadena y volúmenes realistas. Sincronización, consumo de
  recursos, producción de bloques bajo carga y recuperación ante fallos.
- Estabilidad en operación prolongada: semanas de operación continua.
  Sin fugas, sin corrupción, sin degradación.
- Validación cruzada entre nodos: ejecución paralela automatizada contra
  el nodo Haskell, comparación bloque por bloque para detectar
  discrepancias en el estado del ledger.
- Inicio de la auditoría de seguridad con una firma de primer nivel
  (Trail of Bits, NCC Group o equivalente). Corrección del consenso,
  criptografía, manejo de red y resistencia a ataques de denegación de
  servicio.

### T4: Preparación para el Hard Fork Dijkstra e Integración de Leios

#### Objetivo

Alcanzar preparación completa para Dijkstra (incluyendo Plutus V4).
Se espera que Leios y Dijkstra se desplieguen en el mismo hard fork,
por lo que el trabajo de prototipo del T2 alimenta directamente la
integración final en este período.

#### Entregables

- Cambios del protocolo Dijkstra: reglas del ledger, nuevos parámetros
  y modificaciones de gobernanza. Dingo procesará bloques Dijkstra desde
  el momento en que ocurra la bifurcación.
- Plutigo V4: nuevos builtins, modelos de costo actualizados y cualquier
  cambio en el evaluador UPLC.
- Integración del consenso de Leios: llevar el prototipo del T2 a una
  integración completa con el consenso y los cambios del protocolo
  Dijkstra.
- Mini-protocolos pendientes: completar las brechas Node-to-Client y
  LocalStateQuery para lograr paridad de funcionalidades con el nodo
  Haskell. Las herramientas del ecosistema dependen de esto.

### T1 2027: Preparación para Mainnet, Finalización de Auditoría e Integración con el Ecosistema

#### Objetivo

Completar la auditoría, alcanzar la preparación para mainnet y entregar
el trabajo de integración con el ecosistema que haga de Dingo una
herramienta genuinamente útil.

#### Entregables

- Finalización de la auditoría de seguridad. Todos los hallazgos
  atendidos. Los problemas de severidad crítica y alta resueltos antes de
  cualquier recomendación para mainnet. Informe completo publicado.
- Preparación para producción de bloques en mainnet. Aquí converge todo
  el trabajo: consenso, endurecimiento y auditoría. "Preparado" significa
  probado a escala, auditado, estable y capaz de cumplir con todo lo que
  un SPO necesita.
- Integración con el ecosistema: los aspectos prácticos: gestión de
  claves y rotación de KES, compatibilidad con db-sync o indexación
  equivalente, paridad de APIs para wallets, exploradores y dApps.
- Integración con Mithril. Arranque rápido, sincronización en minutos
  en lugar de horas.
- Documentación para operadores: despliegue, configuración, monitoreo y
  resolución de problemas. Lo que se necesita para ejecutar esto en
  producción.
- Endurecimiento P2P: descubrimiento de pares, gestión de conexiones y
  optimización de topología.

---

## 9. Conclusión

Dingo se encuentra más avanzado que la mayoría de las implementaciones
alternativas de nodos al momento de su primera solicitud al tesoro: más
de 300 PRs, 314 pruebas de conformidad aprobadas y Plutus al 100% en
tres versiones. Sin embargo, aún no está preparado para mainnet. Esta
propuesta financia el trabajo necesario para alcanzar ese estado:
completar el consenso, endurecer la operación, realizar una auditoría
rigurosa, implementar soporte para Dijkstra y desarrollar Leios.

Los riesgos son reales: almacenamiento a escala de mainnet, una
especificación de Leios en evolución y los hallazgos que la auditoría
pueda revelar. Hemos planificado para cada uno de ellos: alcance
dedicado, colaboración con IO Engineering, contingencia, custodia
mediante contrato inteligente y supervisión independiente.

#### Después de Doce Meses

- Dingo produce bloques en mainnet.
- Los SPOs cuentan con una alternativa real como productor de bloques.
- Dijkstra funciona desde el primer día.
- Leios existe en Go junto a la referencia en Haskell.
- El informe de auditoría es público.
- Cada ADA se encuentra contabilizado en cadena.

Hemos dedicado años a construir esto. Esta propuesta es lo que convierte
ese esfuerzo en algo de lo que la red pueda depender.

---

## 10. Plan de Participación Comunitaria

Estamos comprometidos con la transparencia y la participación activa de
la comunidad durante todo el ciclo de vida de la propuesta y el período
de desarrollo de doce meses. Christina Gianelloni lidera todas las
actividades de participación comunitaria y operaciones para que el equipo
de ingeniería pueda mantener su enfoque en el desarrollo.

- Foro de Cardano: Hilo dedicado a la propuesta para consultas,
  retroalimentación y debate.
- GovTool: Propuesta publicada con metadatos completos para revisión y
  votación por parte de los DReps.
- Vinculación con DReps: Acercamiento directo con DReps activos para
  presentar la propuesta, responder consultas y atender inquietudes.
- Sesiones de Preguntas y Respuestas (AMA): Sesiones programadas donde
  la comunidad puede formular preguntas sobre detalles técnicos,
  presupuesto y cronogramas.
- X/Twitter: Actualizaciones periódicas sobre avances, hitos y
  discusiones comunitarias.
- Sesiones de Código en Vivo: Sesiones públicas periódicas que
  demuestran el desarrollo activo de Dingo, brindando a la comunidad
  visibilidad directa sobre el trabajo realizado.

Si esta propuesta no es aprobada en primera instancia, incorporaremos la
retroalimentación recibida, realizaremos los ajustes pertinentes y
presentaremos una nueva versión. Agradeceremos su evaluación y su voto
favorable con base en estos avances y compromisos.

---

*Todo el software se publica bajo licencia Apache 2.0. Todo se encuentra
en el
[repositorio treasury-proposal](https://github.com/blinklabs-io/treasury-proposal),
de acceso público.*
