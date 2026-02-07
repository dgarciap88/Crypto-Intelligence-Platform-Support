# Proyectos Crypto a Analizar – V1

Este documento define el conjunto inicial de proyectos crypto que se analizarán en la Crypto Intelligence Platform (CIP).

El objetivo es cubrir:
- Infraestructura base (L1 / L2)
- DeFi con uso real
- Middleware técnico
- Proyectos emergentes con fuerte actividad de desarrollo

Se priorizan proyectos con:
- Repositorios activos en GitHub
- Comunidad real
- Señales técnicas útiles (no hype)

---

## 🟦 Layer 1 (Base del ecosistema)

### 1. Ethereum (ethereum)
**Por qué:**
- Máxima actividad de desarrollo
- Cambios técnicos siempre generan eventos claros
- Ideal para crear baselines de actividad

Repos sugeridos:
- ethereum/go-ethereum  
- ethereum/consensus-specs  

---

### 2. Solana (solana)
**Por qué:**
- Arquitectura distinta a Ethereum
- Mucha actividad técnica
- Social muy ruidoso (buena señal para IA más adelante)

Repos sugeridos:
- solana-labs/solana  

---

## 🟩 Layer 2 (Escalabilidad)

### 3. Arbitrum (arbitrum)
**Por qué:**
- Desarrollo muy activo
- DAO y governance relevantes
- Ecosistema creciendo rápido

Repos sugeridos:
- OffchainLabs/arbitrum  
- OffchainLabs/nitro  

---

### 4. Optimism (optimism)
**Por qué:**
- Buen contraste técnico con Arbitrum
- Mucho movimiento en upgrades y grants

Repos sugeridos:
- ethereum-optimism/optimism  

---

## 🟨 DeFi (Uso real)

### 5. Uniswap (uniswap)
**Por qué:**
- Releases generan eventos claros
- Core de DeFi en Ethereum

Repos sugeridos:
- Uniswap/v3-core  
- Uniswap/interface  

---

### 6. Aave (aave)
**Por qué:**
- Gestión de riesgo constante
- Upgrades frecuentes
- Buenas señales on-chain futuras

Repos sugeridos:
- aave/aave-v3-core  

---

## 🟧 Infraestructura / Middleware

### 7. Chainlink (chainlink)
**Por qué:**
- Integraciones constantes
- Alta actividad técnica

Repos sugeridos:
- smartcontractkit/chainlink  

---

### 8. The Graph (thegraph)
**Por qué:**
- Proyecto altamente técnico
- Ideal para analizar crecimiento real

Repos sugeridos:
- graphprotocol/graph-node  

---

## 🟥 Emergentes estratégicos

### 9. EigenLayer (eigenlayer)
**Por qué:**
- Nueva narrativa de restaking
- Desarrollo muy rápido
- Señales tempranas de adopción

Repos sugeridos:
- Layr-Labs/eigenlayer-contracts  

---

### 10. Celestia (celestia)
**Por qué:**
- Blockchain modular
- Comunidad técnica fuerte

Repos sugeridos:
- celestiaorg/celestia-node  

---

## 🎯 Set inicial recomendado

Para comenzar sin sobrecargar el pipeline:

arbitrum
ethereum
solana
optimism
uniswap
aave
chainlink
thegraph
eigenlayer
celestia


---

## 🚀 Modo de ejecución sugerido

Ejemplo multi-proyecto:

```bash
--project-id arbitrum ethereum solana optimism uniswap aave chainlink thegraph eigenlayer celestia
O modo automático desde configuración:

--all-projects
(leído desde projects.yaml)

📈 Estrategia de escalado
Empezar con 3–5 proyectos

Validar pipeline y métricas

Añadir el resto progresivamente

Nunca empezar con cientos de tokens.

✅ Principio clave
Calidad de señales > cantidad de proyectos

La ventaja competitiva de CIP es entender profundamente cada proyecto, no cubrir todo el mercado.


---

Si quieres, el siguiente MD útil sería uno de:

✅ `projects.yaml` real ya montado con estos repos  
✅ `github-events-spec.md` (qué eventos normalizar)  
✅ `signals-v1.md` (primeras métricas de actividad)

Te puedo generar cualquiera de esos para seguir bajándolo a sistema real.