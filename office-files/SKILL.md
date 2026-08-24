---
name: office-files
description: "处理办公文件：Word (.docx)、Excel (.xlsx/.xls)、PowerPoint (.pptx)、PDF。操作：读取、创建、修改、转换、提取文本/表格/图片、合并拆分 PDF。当用户提到 word、excel、ppt、pdf、文档、表格、幻灯片 等关键词时自动触发。"
---

# Office Files - 办公文件处理

处理 Word、Excel、PowerPoint 和 PDF 文件。所有 Python 操作都使用 `office` conda 虚拟环境。

## 环境准备

每次执行 Python 代码处理办公文件前，必须先激活虚拟环境：

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python <脚本>
```

或者在 Bash 中设置环境变量：
```bash
export CONDA_ENV_PATH=/e/Develop/miniconda3/envs/office
```

## 所有操作的通用规则

- 将复杂操作写成临时 `.py` 文件，通过 `bash` 调用，避免 shell 转义问题
- 写入文件路径使用绝对路径
- 输出结果到 stdout，用 `Read` 查看

---

## 1. Word 文档 (.docx)

### 1.1 读取文本内容

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from docx import Document
doc = Document(r"<文件路径>")
for i, para in enumerate(doc.paragraphs):
    if para.text.strip():
        print(f"[P{i}] {para.text[:200]}")
PYEOF
```

### 1.2 读取所有段落和表格

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from docx import Document

doc = Document(r"<文件路径>")

print("=== 段落 ===")
for i, para in enumerate(doc.paragraphs):
    if para.text.strip():
        print(f"[P{i}] {para.style.name} | {para.text[:300]}")

print("\n=== 表格 ===")
for ti, table in enumerate(doc.tables):
    print(f"\n--- 表格 {ti+1} ({len(table.rows)}行 x {len(table.columns)}列) ---")
    for ri, row in enumerate(table.rows):
        cells = [cell.text.replace('\n', ' ')[:50] for cell in row.cells]
        print(f"  R{ri}: {' | '.join(cells)}")
PYEOF
```

### 1.3 创建新文档

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

doc = Document()

# 标题
title = doc.add_heading('标题', level=1)
title.alignment = WD_ALIGN_PARAGRAPH.CENTER

# 正文
doc.add_paragraph('这是正文内容。')

# 表格
table = doc.add_table(rows=3, cols=3, style='Table Grid')
table.cell(0, 0).text = '列1'
table.cell(0, 1).text = '列2'
table.cell(0, 2).text = '列3'

doc.save(r"<输出路径>.docx")
print("文档已保存")
PYEOF
```

### 1.4 替换文本

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from docx import Document

doc = Document(r"<文件路径>")
old_text = "<旧文本>"
new_text = "<新文本>"

for para in doc.paragraphs:
    if old_text in para.text:
        # 需要逐个 run 替换以保留格式
        for run in para.runs:
            if old_text in run.text:
                run.text = run.text.replace(old_text, new_text)

doc.save(r"<输出路径>.docx")
print("替换完成并保存")
PYEOF
```

---

## 2. Excel 表格 (.xlsx / .xls)

### 2.1 读取 Excel 数据（支持 xlsx 和 xls）

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
import pandas as pd

path = r"<文件路径>"
# 读取所有 sheet
excel = pd.ExcelFile(path)
print(f"Sheet 列表: {excel.sheet_names}")

for sheet in excel.sheet_names:
    df = pd.read_excel(path, sheet_name=sheet, header=None)
    print(f"\n{'='*50}")
    print(f"Sheet: {sheet} ({df.shape[0]}行 x {df.shape[1]}列)")
    print(f"{'='*50}")
    # 显示前 20 行，每列截断
    print(df.head(20).to_string(max_colwidth=30))
PYEOF
```

### 2.2 读取指定 Sheet 的指定列

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
import pandas as pd

df = pd.read_excel(r"<文件路径>", sheet_name="<Sheet名>")
print(df.to_string(max_colwidth=40))
PYEOF
```

### 2.3 创建 Excel 文件

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
import pandas as pd

# 示例数据
data = {
    '姓名': ['张三', '李四', '王五'],
    '年龄': [25, 30, 28],
    '部门': ['技术部', '市场部', '财务部'],
}
df = pd.DataFrame(data)

with pd.ExcelWriter(r"<输出路径>.xlsx", engine='xlsxwriter') as writer:
    df.to_excel(writer, sheet_name='Sheet1', index=False)

print("Excel 文件已保存")
PYEOF
```

### 2.4 使用 openpyxl 修改已有 Excel（保留格式）

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from openpyxl import load_workbook

wb = load_workbook(r"<文件路径>")
ws = wb.active  # 或 wb['Sheet名']

# 修改单元格
ws['A1'] = '新值'
# 读取单元格
print(f"A1 = {ws['A1'].value}")

wb.save(r"<输出路径>.xlsx")
print("修改已保存")
PYEOF
```

---

## 3. PowerPoint 演示文稿 (.pptx)

### 3.1 读取所有幻灯片文本

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from pptx import Presentation

prs = Presentation(r"<文件路径>")

for i, slide in enumerate(prs.slides):
    print(f"\n{'='*40}")
    print(f"幻灯片 {i+1}")
    print(f"{'='*40}")
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                text = para.text.strip()
                if text:
                    print(f"  {text[:200]}")
        if shape.has_table:
            table = shape.table
            print(f"  [表格 {len(table.rows)}x{len(table.columns)}]")
            for ri, row in enumerate(table.rows):
                cells = [cell.text[:30] for cell in row.cells]
                print(f"    R{ri}: {' | '.join(cells)}")
PYEOF
```

### 3.2 创建演示文稿

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from pptx import Presentation
from pptx.util import Inches

prs = Presentation()

# 标题页
slide = prs.slides.add_slide(prs.slide_layouts[0])  # 标题布局
slide.shapes.title.text = "演示标题"
slide.placeholders[1].text = "副标题"

# 内容页
slide2 = prs.slides.add_slide(prs.slide_layouts[1])  # 标题+内容
slide2.shapes.title.text = "内容页标题"
slide2.placeholders[1].text = "这是内容文本。\n可以有多行。"

prs.save(r"<输出路径>.pptx")
print("演示文稿已保存")
PYEOF
```

---

## 4. PDF 文件

### 4.1 提取文本（使用 pdfplumber，精度最高）

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
import pdfplumber

with pdfplumber.open(r"<文件路径>") as pdf:
    print(f"总页数: {len(pdf.pages)}")
    for i, page in enumerate(pdf.pages):
        text = page.extract_text()
        if text:
            print(f"\n--- 第 {i+1} 页 ---")
            print(text[:2000])
PYEOF
```

### 4.2 提取表格

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
import pdfplumber

with pdfplumber.open(r"<文件路径>") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        if tables:
            print(f"\n=== 第 {i+1} 页，共 {len(tables)} 个表格 ===")
            for ti, table in enumerate(tables):
                print(f"\n--- 表格 {ti+1} ---")
                for row in table:
                    print(' | '.join([str(c) if c else '' for c in row]))
PYEOF
```

### 4.3 合并 PDF

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from PyPDF2 import PdfMerger

merger = PdfMerger()
files = [r"<文件1>", r"<文件2>", r"<文件3>"]
for f in files:
    merger.append(f)

merger.write(r"<输出路径>.pdf")
merger.close()
print("PDF 合并完成")
PYEOF
```

### 4.4 拆分 PDF

```bash
source /e/Develop/miniconda3/etc/profile.d/conda.sh && conda activate office && python << 'PYEOF'
from PyPDF2 import PdfReader, PdfWriter

reader = PdfReader(r"<文件路径>")
# 提取第 1-3 页（页码从 0 开始）
writer = PdfWriter()
for i in range(0, min(3, len(reader.pages))):
    writer.add_page(reader.pages[i])

writer.write(r"<输出路径>.pdf")
writer.close()
print("PDF 拆分完成")
PYEOF
```

---

## 快捷操作模版

当你收到处理办公文件的任务时，遵循以下步骤：

1. **识别文件类型** — 根据扩展名（.docx/.xlsx/.pptx/.pdf）选择对应模块
2. **确认操作** — 读取/创建/修改/转换
3. **编写脚本** — 从上述模板中选择对应的 Python 代码
4. **执行** — 通过 Bash 运行，确保先 `source activate office`
5. **验证结果** — 读取生成的文件或用 `Read` 检查输出

## 注意事项

- 文件路径包含中文时，在 Python 字符串前加 `r""` 前缀
- 大文件（>100MB）只读取前若干行/页，避免内存溢出
- xlrd 2.0+ 不再支持 .xlsx，.xls 用 xlrd，.xlsx 用 openpyxl
- pdfplumber 提取表格依赖 PDF 中的线条边界，无边框表格可能提取不完整
