---
name: drawio
description: Always use when user asks to create, generate, draw, or design a diagram, flowchart, architecture diagram, ER diagram, sequence diagram, class diagram, network diagram, mockup, wireframe, or UI sketch, or mentions draw.io, drawio, drawoi, .drawio files, or diagram export to PNG/SVG/PDF.
---

# Draw.io Diagram Skill

Generate draw.io diagrams as native `.drawio` files. Optionally export to PNG, SVG, or PDF with the diagram XML embedded (so the exported file remains editable in draw.io).

## How to create a diagram

1. **Generate draw.io XML** in mxGraphModel format for the requested diagram
2. **Write the XML** to a `.drawio` file in the current working directory using the Write tool
3. **If the user requested an export format** (png, svg, pdf), locate the draw.io CLI (see below), export with `--embed-diagram`, then delete the source `.drawio` file. If the CLI is not found, keep the `.drawio` file and tell the user they can install the draw.io desktop app to enable export, or open the `.drawio` file directly
4. **Open the result** — the exported file if exported, or the `.drawio` file otherwise. If the open command fails, print the file path so the user can open it manually

## Choosing the output format

Check the user's request for a format preference. Examples:

- `/drawio create a flowchart` → `flowchart.drawio`
- `/drawio png flowchart for login` → `login-flow.drawio.png`
- `/drawio svg: ER diagram` → `er-diagram.drawio.svg`
- `/drawio pdf architecture overview` → `architecture-overview.drawio.pdf`

If no format is mentioned, just write the `.drawio` file and open it in draw.io. The user can always ask to export later.

### Supported export formats

| Format | Embed XML | Notes |
|--------|-----------|-------|
| `png` | Yes (`-e`) | Viewable everywhere, editable in draw.io |
| `svg` | Yes (`-e`) | Scalable, editable in draw.io |
| `pdf` | Yes (`-e`) | Printable, editable in draw.io |
| `jpg` | No | Lossy, no embedded XML support |

PNG, SVG, and PDF all support `--embed-diagram` — the exported file contains the full diagram XML, so opening it in draw.io recovers the editable diagram.

## draw.io CLI

The draw.io desktop app includes a command-line interface for exporting.

### Locating the CLI

First, detect the environment, then locate the CLI accordingly:

#### WSL2 (Windows Subsystem for Linux)

WSL2 is detected when `/proc/version` contains `microsoft` or `WSL`:

```bash
grep -qi microsoft /proc/version 2>/dev/null && echo "WSL2"
```

On WSL2, use the Windows draw.io Desktop executable via `/mnt/c/...`:

```bash
DRAWIO_CMD=`/mnt/c/Program Files/draw.io/draw.io.exe`
```

The backtick quoting is required to handle the space in `Program Files` in bash.

If draw.io is installed in a non-default location, check common alternatives:

```bash
# Default install path
`/mnt/c/Program Files/draw.io/draw.io.exe`

# Per-user install (if the above does not exist)
`/mnt/c/Users/$WIN_USER/AppData/Local/Programs/draw.io/draw.io.exe`
```

#### macOS

```bash
/Applications/draw.io.app/Contents/MacOS/draw.io
```

#### Linux (native)

```bash
drawio   # typically on PATH via snap/apt/flatpak
```

#### Windows (native, non-WSL2)

```
"C:\Program Files\draw.io\draw.io.exe"
```

Use `which drawio` (or `where drawio` on Windows) to check if it's on PATH before falling back to the platform-specific path.

### Export command

```bash
drawio -x -f <format> -e -b 10 -o <output> <input.drawio>
```

**WSL2 example:**

```bash
`/mnt/c/Program Files/draw.io/draw.io.exe` -x -f png -e -b 10 -o diagram.drawio.png diagram.drawio
```

Key flags:
- `-x` / `--export`: export mode
- `-f` / `--format`: output format (png, svg, pdf, jpg)
- `-e` / `--embed-diagram`: embed diagram XML in the output (PNG, SVG, PDF only)
- `-o` / `--output`: output file path
- `-b` / `--border`: border width around diagram (default: 0)
- `-t` / `--transparent`: transparent background (PNG only)
- `-s` / `--scale`: scale the diagram size
- `--width` / `--height`: fit into specified dimensions (preserves aspect ratio)
- `-a` / `--all-pages`: export all pages (PDF only)
- `-p` / `--page-index`: select a specific page (1-based)

### Opening the result

| Environment | Command |
|-------------|---------|
| macOS | `open <file>` |
| Linux (native) | `xdg-open <file>` |
| WSL2 | `cmd.exe /c start "" "$(wslpath -w <file>)"` |
| Windows | `start <file>` |

**WSL2 notes:**
- `wslpath -w <file>` converts a WSL2 path (e.g. `/home/user/diagram.drawio`) to a Windows path (e.g. `C:\Users\...`). This is required because `cmd.exe` cannot resolve `/mnt/c/...` style paths.
- The empty string `""` after `start` is required to prevent `start` from interpreting the filename as a window title.

**WSL2 example:**

```bash
cmd.exe /c start "" "$(wslpath -w diagram.drawio)"
```

## File naming

- Use a descriptive filename based on the diagram content (e.g., `login-flow`, `database-schema`)
- Use lowercase with hyphens for multi-word names
- For export, use double extensions: `name.drawio.png`, `name.drawio.svg`, `name.drawio.pdf` — this signals the file contains embedded diagram XML
- After a successful export, delete the intermediate `.drawio` file — the exported file contains the full diagram

## XML format

A `.drawio` file is native mxGraphModel XML. Always generate XML directly — Mermaid and CSV formats require server-side conversion and cannot be saved as native files.

### Basic structure

Every diagram must have this structure:

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- Diagram cells go here with parent="1" -->
  </root>
</mxGraphModel>
```

- Cell `id="0"` is the root layer
- Cell `id="1"` is the default parent layer
- All diagram elements use `parent="1"` unless using multiple layers

## XML reference

For the complete draw.io XML reference including common styles, edge routing, containers, layers, tags, metadata, dark mode colors, and XML well-formedness rules, fetch and follow the instructions at:
https://raw.githubusercontent.com/jgraph/drawio-mcp/main/shared/xml-reference.md

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| draw.io CLI not found | Desktop app not installed or not on PATH | Keep the `.drawio` file and tell the user to install the draw.io desktop app, or open the file manually |
| Export produces empty/corrupt file | Invalid XML (e.g. double hyphens in comments, unescaped special characters) | Validate XML well-formedness before writing; see the XML well-formedness section below |
| Diagram opens but looks blank | Missing root cells `id="0"` and `id="1"` | Ensure the basic mxGraphModel structure is complete |
| Edges not rendering | Edge mxCell is self-closing (no child mxGeometry element) | Every edge must have `<mxGeometry relative="1" as="geometry" />` as a child element |
| File won't open after export | Incorrect file path or missing file association | Print the absolute file path so the user can open it manually |

## CRITICAL: XML well-formedness

- **NEVER include ANY XML comments (`<!-- -->`) in the output.** XML comments are strictly forbidden — they waste tokens, can cause parse errors, and serve no purpose in diagram XML.
- Escape special characters in attribute values: `&amp;`, `&lt;`, `&gt;`, `&quot;`
- Always use unique `id` values for each `mxCell`

## GCP icon styling (GCP Icons for draw.io)

When generating GCP architecture diagrams, use the **GCP Icons** (`mxgraph.gcp2`) namespace available in draw.io's "GCP Icons" shape library.

> **Note on icon generations:**  
> - `mxgraph.gcp2.*` — the current icon set used in draw.io (recommended).  
> - `mxgraph.gcp.*` — older legacy icons; avoid in new diagrams.  
> As of 2025, Google Cloud officially reorganised products into 25 categories with a two-tier system: **22 core product icons** (unique designs) + **category icons** for all other products.

---

### Base style template

Every GCP service icon must use this base style:

```
shape=mxgraph.gcp2.<service_name>;fillColor=<CATEGORY_COLOR>;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;
```

Critical properties:
- **`strokeColor=none`** — GCP icons use no stroke border; the icon graphic is embedded in the shape itself.
- **`fillColor`** — set per service category (see table below). For multi-colour "product card" shapes, use `fillColor=#ffffff` and rely on the shape's built-in colours.
- **`verticalLabelPosition=bottom;verticalAlign=top`** — places the label below the icon.
- **`aspect=fixed`** — prevents icon distortion; always include this.
- **`fontSize=12;fontColor=#3C4043`** — standard GCP label style (dark grey, not black).
- **Icon size:** Use **64×64 px** as the standard icon size. Do **not** resize arbitrarily, as this distorts the shapes.

---

### GCP group containers

Use GCP group shapes to visually separate environments (e.g., GCP boundary, VPC, subnet, region). Child icons inside a group must use `parent="<group_id>"`, and their x/y coordinates are relative to the group's top-left corner.

| Group | Shape / Style | strokeColor | fillColor | Usage |
|-------|--------------|-------------|-----------|-------|
| GCP Cloud boundary | Rectangle (custom) | `#4285F4` | `#F3F6FC` | Top-level GCP boundary box |
| Region | `mxgraph.gcp2.region` | `#4285F4` | `none` | GCP region grouping |
| VPC Network | Rectangle (dashed) | `#34A853` | `none` | Virtual Private Cloud |
| Subnet | Rectangle (dashed) | `#FBBC04` | `none` | Subnetwork boundary |
| Zone | Rectangle (dashed) | `#EA4335` | `none` | Availability zone |
| External / Internet | Rectangle | `#9E9E9E` | `#F5F5F5` | On-premises or internet actors |

**GCP Cloud boundary style template:**

```
rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;fillColor=#F3F6FC;strokeColor=#4285F4;strokeWidth=2;dashed=0;verticalAlign=top;align=left;spacingLeft=10;fontColor=#3C4043;fontSize=13;fontStyle=1;
```

**VPC / Subnet / Zone group style template (dashed border):**

```
rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;fillColor=none;strokeColor=<STROKE_COLOR>;strokeWidth=2;dashed=1;verticalAlign=top;align=left;spacingLeft=10;fontColor=#3C4043;fontSize=12;fontStyle=0;
```

**Example — GCP Cloud boundary with child icons:**

```xml
<mxCell id="gcp_cloud" value="Google Cloud" style="rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;fillColor=#F3F6FC;strokeColor=#4285F4;strokeWidth=2;dashed=0;verticalAlign=top;align=left;spacingLeft=10;fontColor=#3C4043;fontSize=13;fontStyle=1;" vertex="1" parent="1">
  <mxGeometry x="150" y="50" width="900" height="600" as="geometry" />
</mxCell>
<mxCell id="gcs" value="Cloud Storage" style="shape=mxgraph.gcp2.cloud_storage;fillColor=#AECBFA;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="gcp_cloud">
  <mxGeometry x="100" y="200" width="64" height="64" as="geometry" />
</mxCell>
```

Key rules:
- Child cells use `parent="<group_id>"` — their x/y coordinates are **relative** to the group's top-left corner.
- Place external elements (users, on-premises, third-party services) **outside** the GCP Cloud group with `parent="1"`.
- Size the group container large enough to fit all children with at least **40 px padding** on each side.
- Always include the GCP logo shape (`mxgraph.gcp2.google_cloud_platform`) and a title label inside the boundary.

---

### Category color table

GCP icons use category-based fill colours derived from Google's official palette. Apply the `fillColor` to the icon cell.

| Category | fillColor | Example services |
|----------|-----------|-----------------|
| Compute | `#AECBFA` | Compute Engine, Cloud Run, App Engine, Cloud Functions, Batch |
| Containers | `#AECBFA` | GKE, Cloud Run, Artifact Registry, Container Registry |
| Serverless Computing | `#AECBFA` | Cloud Functions, Cloud Run, App Engine |
| Storage | `#E6F4EA` | Cloud Storage, Filestore, Persistent Disk, Hyperdisk |
| Databases | `#FDE7E7` | Cloud SQL, Spanner, Firestore, Bigtable, AlloyDB, Memorystore |
| Networking | `#D2E3FC` | VPC, Cloud Load Balancing, Cloud DNS, Cloud CDN, Cloud NAT, Cloud Armor |
| Data Analytics | `#FEF3E2` | BigQuery, Dataflow, Dataproc, Pub/Sub, Looker Studio |
| AI / Machine Learning | `#E8F0FE` | Vertex AI, Gemini, AutoML, Vision AI, Natural Language AI, Speech-to-Text |
| Security & Identity | `#FCE8E6` | IAM, Cloud KMS, Secret Manager, Security Command Center, Cloud Armor |
| Developer Tools | `#F3E8FD` | Cloud Build, Cloud Code, Artifact Registry, Source Repositories |
| DevOps | `#F3E8FD` | Cloud Deploy, Cloud Build, Artifact Registry |
| Management & Governance | `#E8F5E9` | Cloud Monitoring, Cloud Logging, Cloud Trace, Cloud Profiler, Deployment Manager |
| Hybrid & Multicloud | `#FFF3E0` | Anthos, GKE Enterprise, Apigee Hybrid |
| Integration Services | `#FCE8E6` | Pub/Sub, Eventarc, Workflows, Cloud Tasks, Cloud Scheduler |
| Migration | `#E8F5E9` | Migrate to Virtual Machines, Database Migration Service, Transfer Appliance |
| Business Intelligence | `#FEF3E2` | Looker, Looker Studio, Connected Sheets |
| Observability | `#E8F0FE` | Cloud Monitoring, Cloud Logging, Cloud Trace, Error Reporting |
| General / External | `#F5F5F5` | Users, Internet, On-premises, Third-party services |

> **Tip:** For the most prominent "core product" icons (BigQuery, Cloud Run, Compute Engine, Cloud Storage, etc.), the `mxgraph.gcp2` shapes render in their own built-in colours. In these cases you may use `fillColor=#ffffff` and let the shape's internal design show through, or apply the category colour as a tint background.

---

### Common `mxgraph.gcp2` shape name reference

| Service | Shape name |
|---------|------------|
| Cloud Storage | `cloud_storage` |
| Compute Engine | `compute_engine` |
| Cloud Run | `cloud_run` |
| Cloud Functions | `cloud_functions` |
| GKE / Kubernetes Engine | `container_engine` |
| BigQuery | `bigquery` |
| Cloud SQL | `cloud_sql` |
| Spanner | `cloud_spanner` |
| Firestore | `cloud_firestore` |
| Bigtable | `cloud_bigtable` |
| Pub/Sub | `cloud_pubsub` |
| Dataflow | `cloud_dataflow` |
| Vertex AI | `vertex_ai` |
| Cloud Build | `cloud_build` |
| Cloud Monitoring | `cloud_monitoring` |
| Cloud Logging | `cloud_logging` |
| IAM | `cloud_iam` |
| Secret Manager | `secret_manager` |
| Cloud Load Balancing | `cloud_load_balancing` |
| Cloud DNS | `cloud_dns` |
| Cloud CDN | `cloud_cdn` |
| Cloud NAT | `cloud_nat` |
| VPC | `virtual_private_cloud` |
| App Engine | `app_engine` |
| Cloud Armor | `cloud_armor` |
| Cloud Tasks | `cloud_tasks` |
| Cloud Scheduler | `cloud_scheduler` |
| Eventarc | `eventarc` |
| Artifact Registry | `artifact_registry` |
| Looker | `looker` |
| GCP Platform logo | `google_cloud_platform` |

> Shape names are **lowercase with underscores**. If a shape name is unknown, use a generic placeholder:  
> `shape=mxgraph.gcp2.generic_gcp_service`

---

### Edge / connector style

Use consistent connector styles for GCP diagrams:

```
edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;startArrow=none;endArrow=blockThin;endFill=1;strokeWidth=2;strokeColor=#4285F4;fontColor=#3C4043;fontSize=10;labelBackgroundColor=none;
```

- **Data flow (unidirectional):** `startArrow=none;endArrow=blockThin;endFill=1`
- **Bidirectional:** `startArrow=blockThin;startFill=1;endArrow=blockThin;endFill=1`
- **Internal / administrative:** `strokeColor=#9E9E9E;dashed=1`
- **Flow animation (active paths):** add `flowAnimation=1` to the edge style string

---

### Example — Cloud Storage icon

```xml
<mxCell id="10" value="Cloud Storage" style="shape=mxgraph.gcp2.cloud_storage;fillColor=#E6F4EA;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="64" height="64" as="geometry" />
</mxCell>
```

---

### Example — Complete minimal diagram structure

```xml
<mxfile>
  <diagram id="gcp-arch" name="GCP Architecture">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1654" pageHeight="1169" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />

        <!-- User (external) -->
        <mxCell id="user" value="User" style="shape=mxgraph.gcp2.user;fillColor=#F5F5F5;strokeColor=none;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="1">
          <mxGeometry x="60" y="300" width="64" height="64" as="geometry" />
        </mxCell>

        <!-- GCP Cloud boundary -->
        <mxCell id="gcp_cloud" value="Google Cloud" style="rounded=1;whiteSpace=wrap;html=1;container=1;collapsible=0;recursiveResize=0;fillColor=#F3F6FC;strokeColor=#4285F4;strokeWidth=2;dashed=0;verticalAlign=top;align=left;spacingLeft=10;fontColor=#3C4043;fontSize=13;fontStyle=1;" vertex="1" parent="1">
          <mxGeometry x="200" y="100" width="900" height="600" as="geometry" />
        </mxCell>

        <!-- Cloud Load Balancing (inside GCP boundary) -->
        <mxCell id="lb" value="Cloud Load Balancing" style="shape=mxgraph.gcp2.cloud_load_balancing;fillColor=#D2E3FC;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="gcp_cloud">
          <mxGeometry x="80" y="250" width="64" height="64" as="geometry" />
        </mxCell>

        <!-- Cloud Run (inside GCP boundary) -->
        <mxCell id="cloudrun" value="Cloud Run" style="shape=mxgraph.gcp2.cloud_run;fillColor=#AECBFA;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="gcp_cloud">
          <mxGeometry x="280" y="250" width="64" height="64" as="geometry" />
        </mxCell>

        <!-- Cloud Storage (inside GCP boundary) -->
        <mxCell id="gcs" value="Cloud Storage" style="shape=mxgraph.gcp2.cloud_storage;fillColor=#E6F4EA;strokeColor=none;dashed=0;html=1;verticalLabelPosition=bottom;verticalAlign=top;align=center;fontSize=12;fontStyle=0;fontColor=#3C4043;aspect=fixed;" vertex="1" parent="gcp_cloud">
          <mxGeometry x="480" y="250" width="64" height="64" as="geometry" />
        </mxCell>

        <!-- Edge: User → Load Balancer -->
        <mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;startArrow=none;endArrow=blockThin;endFill=1;strokeWidth=2;strokeColor=#4285F4;" edge="1" source="user" target="lb" parent="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Edge: Load Balancer → Cloud Run -->
        <mxCell id="e2" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;startArrow=none;endArrow=blockThin;endFill=1;strokeWidth=2;strokeColor=#4285F4;" edge="1" source="lb" target="cloudrun" parent="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

        <!-- Edge: Cloud Run → Cloud Storage -->
        <mxCell id="e3" style="edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;startArrow=none;endArrow=blockThin;endFill=1;strokeWidth=2;strokeColor=#4285F4;" edge="1" source="cloudrun" target="gcs" parent="1">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>

      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

---

### Quick reference: Key differences from AWS style

| Aspect | AWS (mxgraph.aws4) | GCP (mxgraph.gcp2) |
|--------|-------------------|-------------------|
| Shape pattern | `resIcon=mxgraph.aws4.<name>` + `shape=mxgraph.aws4.resourceIcon` | `shape=mxgraph.gcp2.<name>` (direct) |
| strokeColor | `#ffffff` (white lines on coloured bg) | `none` (no border) |
| fillColor | Category colour (icon background) | Category colour (light tint) |
| fontColor | `#232F3E` (dark navy) | `#3C4043` (dark grey) |
| Icon size | 60×60 px | 64×64 px |
| Cloud boundary | `mxgraph.aws4.group_aws_cloud_alt` shape | Rectangle with `strokeColor=#4285F4` |
| Label position | `verticalLabelPosition=bottom` | `verticalLabelPosition=bottom` |