"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { useRouter } from "next/navigation"
import type { MessageTemplate } from "@/lib/types"
import { Trash2, Plus, Edit2, X, Check, Wand2 } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"

interface TemplatesListProps {
  templates: MessageTemplate[]
  canManage: boolean
  tenantId: string | null
}

export function TemplatesList({ templates, canManage, tenantId }: TemplatesListProps) {
  const [isAdding, setIsAdding] = useState(false)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  const [formData, setFormData] = useState({
    name: "",
    language_code: "pt_BR",
    description: "",
    template_text: "",
    parameter_mapping: {} as Record<string, string>,
  })

  const [extractedVariables, setExtractedVariables] = useState<string[]>([])

  useEffect(() => {
    const regex = /\{\{(\d+)\}\}/g
    const matches = formData.template_text.matchAll(regex)
    const variables = [...new Set([...matches].map((m) => m[1]))].sort((a, b) => Number(a) - Number(b))
    setExtractedVariables(variables)

    // Initialize mapping for new variables
    const newMapping = { ...formData.parameter_mapping }
    variables.forEach((v) => {
      if (!(v in newMapping)) {
        newMapping[v] = ""
      }
    })
    // Remove old variables not in template
    Object.keys(newMapping).forEach((key) => {
      if (!variables.includes(key)) {
        delete newMapping[key]
      }
    })
    if (JSON.stringify(newMapping) !== JSON.stringify(formData.parameter_mapping)) {
      setFormData((prev) => ({ ...prev, parameter_mapping: newMapping }))
    }
  }, [formData.template_text])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!tenantId) {
      setError("Você precisa estar vinculado a uma empresa")
      return
    }

    // Validate all variables are mapped
    const unmapped = extractedVariables.filter((v) => !formData.parameter_mapping[v])
    if (unmapped.length > 0) {
      setError(`Mapeie todos os parâmetros: {{${unmapped.join("}}, {{")}}}`)
      return
    }

    setIsLoading(true)
    setError(null)

    const supabase = createClient()

    const dataToSave = {
      name: formData.name,
      language_code: formData.language_code,
      description: formData.description,
      template_text: formData.template_text,
      parameter_mapping: formData.parameter_mapping,
    }

    if (editingId) {
      const { error: updateError } = await supabase.from("message_templates").update(dataToSave).eq("id", editingId)

      if (updateError) {
        setError(updateError.message)
      } else {
        setEditingId(null)
        resetForm()
        router.refresh()
      }
    } else {
      const { error: insertError } = await supabase.from("message_templates").insert({
        ...dataToSave,
        tenant_id: tenantId,
      })

      if (insertError) {
        setError(insertError.message)
      } else {
        setIsAdding(false)
        resetForm()
        router.refresh()
      }
    }
    setIsLoading(false)
  }

  const resetForm = () => {
    setFormData({
      name: "",
      language_code: "pt_BR",
      description: "",
      template_text: "",
      parameter_mapping: {},
    })
    setExtractedVariables([])
  }

  const handleEdit = (template: MessageTemplate) => {
    setEditingId(template.id)
    setFormData({
      name: template.name,
      language_code: template.language_code,
      description: template.description || "",
      template_text: (template as any).template_text || "",
      parameter_mapping: template.parameter_mapping || {},
    })
  }

  const handleDelete = async (id: string) => {
    if (!confirm("Tem certeza que deseja excluir este template?")) return

    const supabase = createClient()
    await supabase.from("message_templates").delete().eq("id", id)
    router.refresh()
  }

  const handleCancel = () => {
    setIsAdding(false)
    setEditingId(null)
    resetForm()
  }

  const updateParameterMapping = (variable: string, value: string) => {
    setFormData((prev) => ({
      ...prev,
      parameter_mapping: {
        ...prev.parameter_mapping,
        [variable]: value,
      },
    }))
  }

  if (!canManage && templates.length === 0) {
    return <p className="text-sm text-muted-foreground">Nenhum template configurado.</p>
  }

  return (
    <div className="space-y-4">
      {templates.map((template) => (
        <div key={template.id}>
          {editingId === template.id ? (
            <form onSubmit={handleSubmit} className="space-y-4 rounded-md border p-4">
              <FormFields
                formData={formData}
                setFormData={setFormData}
                extractedVariables={extractedVariables}
                updateParameterMapping={updateParameterMapping}
              />
              {error && <p className="text-sm text-destructive">{error}</p>}
              <div className="flex gap-2">
                <Button type="submit" size="sm" disabled={isLoading}>
                  <Check className="mr-2 h-4 w-4" />
                  {isLoading ? "Salvando..." : "Salvar"}
                </Button>
                <Button type="button" variant="outline" size="sm" onClick={handleCancel}>
                  <X className="mr-2 h-4 w-4" />
                  Cancelar
                </Button>
              </div>
            </form>
          ) : (
            <div className="flex items-start justify-between rounded-md border p-4">
              <div className="space-y-2 flex-1">
                <div className="flex items-center gap-2">
                  <p className="font-medium">{template.name}</p>
                  <Badge variant="secondary">{template.language_code}</Badge>
                </div>
                {template.description && <p className="text-sm text-muted-foreground">{template.description}</p>}
                {Object.keys(template.parameter_mapping || {}).length > 0 && (
                  <div className="flex flex-wrap gap-2 mt-2">
                    {Object.entries(template.parameter_mapping || {}).map(([key, value]) => (
                      <Badge key={key} variant="outline" className="text-xs">
                        {`{{${key}}}`} → {value as string}
                      </Badge>
                    ))}
                  </div>
                )}
              </div>
              {canManage && (
                <div className="flex gap-1">
                  <Button variant="ghost" size="icon" onClick={() => handleEdit(template)}>
                    <Edit2 className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="icon" onClick={() => handleDelete(template.id)}>
                    <Trash2 className="h-4 w-4 text-destructive" />
                  </Button>
                </div>
              )}
            </div>
          )}
        </div>
      ))}

      {canManage && (
        <>
          {isAdding ? (
            <form onSubmit={handleSubmit} className="space-y-4 rounded-md border p-4">
              <FormFields
                formData={formData}
                setFormData={setFormData}
                extractedVariables={extractedVariables}
                updateParameterMapping={updateParameterMapping}
              />
              {error && <p className="text-sm text-destructive">{error}</p>}
              <div className="flex gap-2">
                <Button type="submit" disabled={isLoading}>
                  {isLoading ? "Salvando..." : "Criar Template"}
                </Button>
                <Button type="button" variant="outline" onClick={handleCancel}>
                  Cancelar
                </Button>
              </div>
            </form>
          ) : (
            <Button onClick={() => setIsAdding(true)} variant="outline" className="w-full">
              <Plus className="mr-2 h-4 w-4" />
              Adicionar Template
            </Button>
          )}
        </>
      )}
    </div>
  )
}

function FormFields({
  formData,
  setFormData,
  extractedVariables,
  updateParameterMapping,
}: {
  formData: {
    name: string
    language_code: string
    description: string
    template_text: string
    parameter_mapping: Record<string, string>
  }
  setFormData: (data: typeof formData) => void
  extractedVariables: string[]
  updateParameterMapping: (variable: string, value: string) => void
}) {
  return (
    <>
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="grid gap-2">
          <Label htmlFor="template_name">Nome do Template (WhatsApp)</Label>
          <Input
            id="template_name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            placeholder="aviso_partida"
            required
          />
        </div>
        <div className="grid gap-2">
          <Label htmlFor="language_code">Código do Idioma</Label>
          <Input
            id="language_code"
            value={formData.language_code}
            onChange={(e) => setFormData({ ...formData, language_code: e.target.value })}
            placeholder="pt_BR"
            required
          />
        </div>
      </div>

      <div className="grid gap-2">
        <Label htmlFor="description">Descrição</Label>
        <Input
          id="description"
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          placeholder="Aviso de partida para passageiros"
        />
      </div>

      <div className="grid gap-2">
        <Label htmlFor="template_text" className="flex items-center gap-2">
          <Wand2 className="h-4 w-4" />
          Texto do Template (Meta)
        </Label>
        <Textarea
          id="template_text"
          value={formData.template_text}
          onChange={(e) => setFormData({ ...formData, template_text: e.target.value })}
          placeholder={`Cole aqui o texto do template da Meta, exemplo:

Olá Sr(a) {{1}}
Aqui é da empresa Penha Solutions, tudo bem?
{{2}}
Serviço: {{3}}
Data: {{4}}
Horário da saída: {{5}}
...`}
          rows={8}
          className="font-mono text-sm"
        />
        <p className="text-xs text-muted-foreground">
          Cole o texto exato do template cadastrado na Meta. As variáveis {"{{1}}"}, {"{{2}}"}, etc. serão detectadas
          automaticamente.
        </p>
      </div>

      {extractedVariables.length > 0 && (
        <Card className="bg-muted/50">
          <CardContent className="pt-4">
            <Label className="text-sm font-medium mb-3 block">
              Mapeamento de Variáveis ({extractedVariables.length} encontradas)
            </Label>
            <div className="grid gap-3">
              {extractedVariables.map((variable) => (
                <div key={variable} className="flex items-center gap-3">
                  <Badge variant="secondary" className="w-16 justify-center font-mono">
                    {`{{${variable}}}`}
                  </Badge>
                  <span className="text-muted-foreground">→</span>
                  <Input
                    value={formData.parameter_mapping[variable] || ""}
                    onChange={(e) => updateParameterMapping(variable, e.target.value)}
                    placeholder={`Campo da API para {{${variable}}}`}
                    className="flex-1"
                  />
                </div>
              ))}
            </div>
            <p className="text-xs text-muted-foreground mt-3">
              Informe o nome do campo retornado pela API que corresponde a cada variável do template.
              <br />
              Exemplos: nome_pax, servico, data_partida, horario_saida, origem, destino, voo, horario_voo
            </p>
          </CardContent>
        </Card>
      )}
    </>
  )
}
