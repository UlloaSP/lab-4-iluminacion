# Lab 4: Iluminación en Godot

**IGM: Interación, Gráficos e Multimedia**
Mestrado Universitario en Enxeñería Informática (MUEI) — Universidade da Coruña

| | |
|---|---|
| **Autores** | Francisco Javier Espada Radío |
| | Pablo Mendez Vazquez |
| | Pablo Ulloa Santín |

---

## Descrición do proxecto

Escena interactiva en Godot 4.6 (Forward+) baseada nunha **Cornell Box simplificada** que permite comparar o modelo de iluminación **PBR** (predeterminado de Godot) co modelo clásico de **Phong** implementado mediante un `ShaderMaterial`.

---

## Controis

| Tecla | Acción |
|-------|--------|
| F7 | Cámara fixa exterior (vista completa) |
| F8 | Cámara fixa interior (tiro alto) |
| F9 | Cámara FPS (WASD + rato) |
| 1 | Activar/desactivar Luz 1 (DirectionalLight3D) |
| 2 | Activar/desactivar Luz 2 (OmniLight3D lateral) |
| 3 | Activar/desactivar Luz 3 (OmniLight3D superior) |
| O | Activar/desactivar Ambient Occlusion (SSAO) |
| E | Activar/desactivar WorldEnvironment (Sky) |
| Esc | Liberar cursor do rato (en modo FPS) |

---

## Observacións experimentais

### 1. Cambios no highlight especular

- **PBR (Esferas A e B):** O highlight especular responde ao parámetro `roughness`. Na esfera A (plástico, roughness = 0.4) obsérvase un reflexo especular amplo e suave. Na esfera B (metal, roughness = 0.2) o reflexo é máis concentrado e brillante, con cor influída polo propio albedo da superficie (comportamento metálico do PBR).
- **Phong (Esfera C):** O highlight especular é controlado directamente polo expoñente `shininess` (16.0). O reflexo ten forma máis simple e circular, sen variar en función do ángulo de visión. É un punto brillante branco uniforme, independente da cor do material.
- **Diferenza clave:** En PBR o especular depende da combinación metallic/roughness e responde á enerxía das luces de forma fisicamente consistente. En Phong o especular é un cálculo empírico (`pow(dot(V, R), shininess)`) que non conserva enerxía.

### 2. Comportamento do Fresnel

- **PBR (Esferas A e B):** Godot aplica automaticamente o efecto Fresnel mediante a aproximación de Schlick. Nos bordos das esferas (ángulos rasantes) obsérvase un aumento da reflectividade. Na esfera A (plástico) os bordos vólvense máis brillantes. Na esfera B (metal) o efecto é menos visible porque os metais xa teñen alta reflectividade a todos os ángulos.
- **Phong (Esfera C):** Non hai efecto Fresnel. A reflectividade especular é uniforme en todos os ángulos de visión. Isto fai que a esfera Phong pareza máis "plana" e menos realista nos bordos comparada coas esferas PBR.
- **Diferenza clave:** O Fresnel é unha propiedade física real que PBR simula e Phong ignora. Apágase ao ver a Esfera C con iluminación rasante: non ten o borde luminoso que si teñen A e B.

### 3. Efecto da suma de múltiples luces

- **PBR (Esferas A e B):** Ao engadir luces, a contribución de cada unha é acumulativa pero respecta a conservación de enerxía. As superficies non se sobreexpoñen facilmente porque o BRDF de Godot (GGX/Smith) distribúe a enerxía de forma fisicamente plausible. O resultado é un incremento gradual e natural da iluminación.
- **Phong (Esfera C):** Cada luz engade a súa contribución difusa e especular de forma lineal (`DIFFUSE_LIGHT +=`, `SPECULAR_LIGHT +=`). Non hai conservación de enerxía intrínseca no modelo. Ao activar as 3 luces simultaneamente, a esfera C pode parecer máis brillante do esperado, e os highlights especulares acumúlanse sen límite físico, podendo saturar.
- **Diferenza clave:** Activando e desactivando luces con 1/2/3 obsérvase que PBR mantén coherencia visual mentres Phong pode resultar en sobreexposición cando múltiples luces inciden sobre a superficie.

### 4. Percepción do contacto co chan (AO)

- **Con SSAO activado (tecla O):** Aparece un sombreado sutil nas zonas de contacto entre as esferas e o chan, e entre os prismas e o chan. Este efecto simula a oclusión ambiental: nas cavidades e recunchos a luz ambiental chega con máis dificultade, xerando sombras suaves de contacto.
- **Sen SSAO:** As esferas parecen "flotar" lixeiramente sobre o chan ao perder esa sombra de contacto. A percepción de ancoraxe ao solo diminúe notablemente.
- **Efecto sobre cada modelo:** O SSAO é un efecto de post-procesado que se aplica por igual a PBR e Phong. Ambos modelos se benefician igualmente desta técnica. Non obstante, como PBR xa produce sombras e transicións máis ricas grazas ao seu BRDF, a combinación PBR + AO resulta máis convincente visualmente que Phong + AO.

---

## Pregunta clave: Que diferenzas aparecen entre Phong e PBR ao variar o contexto de iluminación?

As principais diferenzas observadas son:

1. **Conservación de enerxía:** PBR conserva enerxía (a suma de luz difusa e especular reflectida nunca excede a luz incidente). Phong non ten esta restrición, polo que pode producir resultados sobreexpostos con múltiples luces ou valores altos de `specular_strength`.

2. **Resposta ao entorno (Environment):** Ao activar/desactivar o Sky (tecla E), as esferas PBR reaccionan ao ambiente: as reflexións do ceo aparecen na superficie (especialmente na esfera B metálica) e a luz ambiental do ceo tíñe sutilmente as superficies. A esfera Phong (C) non recibe reflexións do environment porque o seu shader personalizado non procesa a luz ambiental do entorno da mesma maneira — só ten unha compoñente `EMISSION` fixa como aproximación ao termo ambiental.

3. **Realismo nos bordos (Fresnel):** PBR produce bordos máis brillantes nos ángulos rasantes (efecto Fresnel), dando maior sensación de volume e tridimensionalidade. Phong mantén unha reflectividade uniforme que resulta menos realista.

4. **Comportamento metálico vs. dieléctrico:** PBR distingue claramente entre materiais metálicos (especular coloreado polo albedo, case sen difuso) e dieléctricos (especular branco, difuso coloreado). Phong non fai esta distinción: o especular é sempre branco independentemente do tipo de material.

5. **Variación co contexto de iluminación:** Ao cambiar as luces activas, PBR adapta as proporcións difuso/especular de forma consistente en calquera configuración. Phong pode parecer correcto cunha soa luz pero perder coherencia visual cando o contexto cambia (múltiples luces, luz ambiental forte, etc.).

En resumo, PBR proporciona resultados visualmente consistentes e fisicamente plausibles baixo calquera configuración de iluminación, mentres que Phong require axustes manuais dos seus parámetros para cada escenario concreto.

---

## Texturas

Incorporouse o uso de texturas de albedo (mapa difuso) en todas as superficies da escena:

- **Chan:** textura de baldosa con xuntas de morteiro
- **Paredes:** textura de enlucido/pintura con variación sutil
- **Prismas:** textura de veta de madeira con patrón de aneis
- **Esferas A, B e C:** texturas de detalle (plástico, metal cepillado e cerámica)

As texturas actúan como mapas de detalle neutros (tons próximos ao branco) e o `albedo_color` de cada material controla a tonalidade final. No shader Phong (Esfera C) a textura modula a compoñente difusa a través dun `sampler2D` no `fragment()`.

### Orixe das texturas

Ao buscar texturas gratuítas en repositorios web (ambientCG, Polyhaven, etc.), non se atoparon mapas de albedo difusos que cumprisen o requisito de ser neutros en cor (próximos ao branco/gris) sen alterar a tonalidade definida polo `albedo_color` do material. As texturas dispoñibles gratuitamente xa incorporaban cor propia, rugosidade visual ou outros canais mesturados, o que interfería co comportamento desexado dos materiais PBR da escena.

Por este motivo, as texturas foron xeradas mediante IA utilizando o modelo de xeración de imaxes de OpenAI (DALL-E). Isto permitiu solicitar especificamente mapas de detalle neutros, con patróns de superficie realistas (baldosa, enlucido, veta de madeira, metal cepillado, cerámica) pero sen cor dominante, para que o `albedo_color` de cada material fose o único responsable da tonalidade final.

