# Pure Python PDF Generator for DimDim Delivery Document (No external dependencies)
import zlib
import os

class SimplePDF:
    def __init__(self):
        self.pages = []
        self.current_page_stream = []
        self.y = 800
        self.page_num = 1

    def new_page(self):
        if self.current_page_stream:
            self.pages.append("\n".join(self.current_page_stream))
            self.current_page_stream = []
            self.page_num += 1
            self.y = 800

    def add_text(self, text, size=11, bold=False, x=50, color=(0,0,0)):
        font = "F2" if bold else "F1"
        r, g, b = color
        stream = f"""BT
/{font} {size} Tf
{r:.2f} {g:.2f} {b:.2f} rg
1 0 0 1 {x} {self.y} Tm
({self.escape_pdf(text)}) Tj
ET"""
        self.current_page_stream.append(stream)
        self.y -= int(size * 1.35) + 3

    def add_space(self, pts=10):
        self.y -= pts

    def add_line(self, x1=50, x2=550, color=(0.7,0.7,0.7), width=1):
        r, g, b = color
        stream = f"""{r:.2f} {g:.2f} {b:.2f} RG
{width} w
{x1} {self.y} m
{x2} {self.y} l
S"""
        self.current_page_stream.append(stream)
        self.y -= 8

    def escape_pdf(self, text):
        return text.replace('\\', '\\\\').replace('(', '\\(').replace(')', '\\)')

    def build(self, filename):
        if self.current_page_stream:
            self.pages.append("\n".join(self.current_page_stream))

        objects = []
        # Obj 1: Catalog
        objects.append("1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n")
        
        # Obj 2: Pages
        page_refs = [f"{i*2 + 4} 0 R" for i in range(len(self.pages))]
        objects.append(f"2 0 obj\n<< /Type /Pages /Kids [{' '.join(page_refs)}] /Count {len(self.pages)} >>\nendobj\n")
        
        # Obj 3: Fonts (F1=Helvetica, F2=Helvetica-Bold, F3=Courier)
        objects.append("""3 0 obj
<<
  /Font <<
    /F1 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>
    /F2 << /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>
    /F3 << /Type /Font /Subtype /Type1 /BaseFont /Courier >>
  >>
>>
endobj
""")

        obj_index = 4
        for page_content in self.pages:
            content_bytes = page_content.encode('latin1', errors='replace')
            content_obj = f"{obj_index+1} 0 obj\n<< /Length {len(content_bytes)} >>\nstream\n{page_content}\nendstream\nendobj\n"
            page_obj = f"{obj_index} 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents {obj_index+1} 0 R /Resources 3 0 R >>\nendobj\n"
            objects.append(page_obj)
            objects.append(content_obj)
            obj_index += 2

        # Build xref table
        header = "%PDF-1.4\n%\xe2\xe3\xcf\xd3\n"
        offsets = []
        current_offset = len(header)
        body = ""
        for obj in objects:
            offsets.append(current_offset)
            body += obj
            current_offset += len(obj.encode('latin1', errors='replace'))

        xref_offset = len(header) + len(body.encode('latin1', errors='replace'))
        xref = f"xref\n0 {len(objects)+1}\n0000000000 65535 f \n"
        for off in offsets:
            xref += f"{off:010d} 00000 n \n"

        trailer = f"trailer\n<< /Size {len(objects)+1} /Root 1 0 R >>\nstartxref\n{xref_offset}\n%%EOF"
        
        with open(filename, 'wb') as f:
            f.write(header.encode('latin1') + body.encode('latin1', errors='replace') + xref.encode('latin1') + trailer.encode('latin1'))

pdf = SimplePDF()

# --- PAGINA 1: FOLHA DE ROSTO & INTEGRANTES ---
pdf.add_text("FIAP - TECNOLOGIA EM DESENVOLVIMENTO DE SISTEMAS", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_text("DevOps Tools & Cloud Computing - Prof. Joao Menk", size=11, bold=False, color=(0.3, 0.3, 0.3))
pdf.add_line()
pdf.add_space(15)

pdf.add_text("1o CHECKPOINT 2o SEMESTRE - PROJETO DIMDIM", size=18, bold=True, color=(0.85, 0.15, 0.2))
pdf.add_text("Conteinerizacao de App e Banco em Nuvem no Formato PaaS (ACR & ACI)", size=12, bold=True, color=(0.2, 0.2, 0.2))
pdf.add_space(15)

pdf.add_text("INTEGRANTES DO GRUPO:", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_text("1. Gabriel Maciel Alves de Oliveira (RM562795) - Representante", size=11, bold=True)
pdf.add_text("2. Vitoria Rodrigues Martins (RM565160)", size=11)
pdf.add_text("3. Augusto Bonomo Junior (RM565155)", size=11)
pdf.add_text("4. Thomas Fontes (RM562254)", size=11)
pdf.add_text("5. Matheus Pereira Molina (RM563399)", size=11)
pdf.add_space(15)

pdf.add_text("LINKS OFICIAIS DE ENTREGA:", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_text("Repositorio GitHub: https://github.com/Gabriel-Maciel06/devops-cp1-dimdim-azure", size=10.5, bold=True, color=(0, 0.4, 0.8))
pdf.add_text("Video de Demonstracao (YouTube): https://youtu.be/sOJWAZk0AmU?is=WEzSpdxw0hyJ5_0e", size=10.5, bold=True, color=(0.85, 0.15, 0.2))
pdf.add_text("Swagger UI (Nuvem Azure): http://app-dimdim-rm562795.chilecentral.azurecontainer.io:8080/swagger-ui.html", size=10)
pdf.add_space(15)

pdf.add_text("RESUMO DOS RECURSOS AZURE (PaaS):", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_text("- Resource Group: rg-dimdim-rm562795 (Regiao: chilecentral)", size=10.5)
pdf.add_text("- Azure Container Registry (ACR): acrdimdim562795.azurecr.io", size=10.5)
pdf.add_text("- Imagem DB: acrdimdim562795.azurecr.io/rm562795-dimdim-db:latest", size=10.5)
pdf.add_text("- Imagem App: acrdimdim562795.azurecr.io/rm562795-dimdim-app:latest (Usuario Non-Root)", size=10.5)
pdf.add_text("- ACI Banco de Dados: rm562795-dimdim-db (PostgreSQL 16 com Azure File Share)", size=10.5)
pdf.add_text("- ACI Aplicacao: rm562795-dimdim-app (Java 21 / Spring Boot 3.3)", size=10.5)
pdf.add_text("- Storage Account: stdimdim562795 (Share: db-dimdim-share montado em /var/lib/postgresql/data)", size=10.5)

# --- PAGINA 2: DDL DO BANCO & HOW-TO CLI ---
pdf.new_page()
pdf.add_text("1. SCRIPT DDL DAS TABELAS (PostgreSQL)", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_line()
pdf.add_text("CREATE TABLE TB_DIMDIM_TRANSACOES (", size=9.5, bold=True)
pdf.add_text("    ID BIGSERIAL PRIMARY KEY,", size=9.5)
pdf.add_text("    DESCRICAO VARCHAR(150) NOT NULL,", size=9.5)
pdf.add_text("    VALOR NUMERIC(12, 2) NOT NULL,", size=9.5)
pdf.add_text("    TIPO VARCHAR(10) NOT NULL,", size=9.5)
pdf.add_text("    CATEGORIA VARCHAR(50) NOT NULL,", size=9.5)
pdf.add_text("    DATA_TRANSACAO TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,", size=9.5)
pdf.add_text("    CONSTRAINT CK_VALOR_POSITIVO CHECK (VALOR > 0),", size=9.5)
pdf.add_text("    CONSTRAINT CK_TIPO_VALIDO CHECK (TIPO IN ('ENTRADA', 'SAIDA'))", size=9.5)
pdf.add_text(");", size=9.5, bold=True)
pdf.add_space(15)

pdf.add_text("2. HOW-TO: COMANDOS AZURE CLI DE PROVISIONAMENTO", size=13, bold=True, color=(0.1, 0.2, 0.5))
pdf.add_line()
pdf.add_text("# 1. Criar Grupo de Recursos e Storage Account com File Share", size=9.5, color=(0.3,0.3,0.3))
pdf.add_text("az group create --name rg-dimdim-rm562795 --location chilecentral", size=9)
pdf.add_text("az storage account create --name stdimdim562795 --resource-group rg-dimdim-rm562795 --sku Standard_LRS", size=9)
pdf.add_text("az storage share create --name db-dimdim-share --account-name stdimdim562795", size=9)
pdf.add_space(8)

pdf.add_text("# 2. Criar ACR, Realizar Build e Push das Imagens", size=9.5, color=(0.3,0.3,0.3))
pdf.add_text("az acr create --resource-group rg-dimdim-rm562795 --name acrdimdim562795 --sku Basic --admin-enabled true", size=9)
pdf.add_text("az acr login --name acrdimdim562795", size=9)
pdf.add_text("docker build -t acrdimdim562795.azurecr.io/rm562795-dimdim-db:latest ./db", size=9)
pdf.add_text("docker push acrdimdim562795.azurecr.io/rm562795-dimdim-db:latest", size=9)
pdf.add_text("docker build -t acrdimdim562795.azurecr.io/rm562795-dimdim-app:latest ./app", size=9)
pdf.add_text("docker push acrdimdim562795.azurecr.io/rm562795-dimdim-app:latest", size=9)
pdf.add_space(8)

pdf.add_text("# 3. Criar ACI do Banco de Dados com Persistencia no Azure Files", size=9.5, color=(0.3,0.3,0.3))
pdf.add_text("az container create --resource-group rg-dimdim-rm562795 --name rm562795-dimdim-db \\", size=9)
pdf.add_text("  --image acrdimdim562795.azurecr.io/rm562795-dimdim-db:latest --ports 5432 --ip-address Public \\", size=9)
pdf.add_text("  --dns-name-label db-dimdim-rm562795 --azure-file-volume-share-name db-dimdim-share ...", size=9)
pdf.add_space(8)

pdf.add_text("# 4. Criar ACI da Aplicacao DimDim (Non-root user)", size=9.5, color=(0.3,0.3,0.3))
pdf.add_text("az container create --resource-group rg-dimdim-rm562795 --name rm562795-dimdim-app \\", size=9)
pdf.add_text("  --image acrdimdim562795.azurecr.io/rm562795-dimdim-app:latest --ports 8080 --ip-address Public \\", size=9)
pdf.add_text("  --dns-name-label app-dimdim-rm562795 --environment-variables SPRING_DATASOURCE_URL=... ...", size=9)

# Output files
out1 = "/Users/gabrieloliveira/Desktop/Agentes-cloud/devops-cp1-dimdim-azure/DimDim_container.pdf"

pdf.build(out1)
print("PDF generated successfully at:", out1)
