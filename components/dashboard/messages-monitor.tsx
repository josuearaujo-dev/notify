"use client"

import type React from "react"

import { useState } from "react"
import type { Message } from "@/lib/types"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Card, CardContent } from "@/components/ui/card"
import { ScrollArea } from "@/components/ui/scroll-area"
import { formatDistanceToNow, format } from "date-fns"
import { ptBR } from "date-fns/locale"
import { CheckCircle, Clock, Eye, Search, Send, XCircle, History, RefreshCw } from "lucide-react"
import { createBrowserClient } from "@supabase/ssr"

interface MessagesMonitorProps {
  messages: Message[]
}

const statusConfig: Record<
  string,
  { label: string; variant: "default" | "secondary" | "destructive" | "outline"; icon: React.ReactNode; color: string }
> = {
  pending: { label: "Pendente", variant: "secondary", icon: <Clock className="h-3 w-3" />, color: "text-yellow-500" },
  sent: { label: "Enviado", variant: "outline", icon: <Send className="h-3 w-3" />, color: "text-blue-500" },
  delivered: {
    label: "Entregue",
    variant: "default",
    icon: <CheckCircle className="h-3 w-3" />,
    color: "text-green-500",
  },
  read: { label: "Lido", variant: "default", icon: <Eye className="h-3 w-3" />, color: "text-emerald-500" },
  failed: { label: "Falhou", variant: "destructive", icon: <XCircle className="h-3 w-3" />, color: "text-red-500" },
}

interface StatusHistory {
  id: string
  status: string
  timestamp: string
  raw_payload?: Record<string, unknown>
}

export function MessagesMonitor({ messages: initialMessages }: MessagesMonitorProps) {
  const [messages, setMessages] = useState(initialMessages)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState<string>("all")
  const [selectedMessage, setSelectedMessage] = useState<Message | null>(null)
  const [statusHistory, setStatusHistory] = useState<StatusHistory[]>([])
  const [loadingHistory, setLoadingHistory] = useState(false)
  const [refreshing, setRefreshing] = useState(false)

  const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  )

  const filteredMessages = messages.filter((message) => {
    const matchesSearch =
      message.recipient_phone?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      message.template_name?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = statusFilter === "all" || message.status === statusFilter
    return matchesSearch && matchesStatus
  })

  const handleRefresh = async () => {
    setRefreshing(true)
    try {
      const { data } = await supabase.from("messages").select("*").order("created_at", { ascending: false }).limit(200)

      if (data) {
        setMessages(data)
      }
    } finally {
      setRefreshing(false)
    }
  }

  const handleViewHistory = async (message: Message) => {
    setSelectedMessage(message)
    setLoadingHistory(true)

    try {
      const { data } = await supabase
        .from("message_status_history")
        .select("*")
        .eq("message_id", message.id)
        .order("timestamp", { ascending: true })

      setStatusHistory(data || [])
    } finally {
      setLoadingHistory(false)
    }
  }

  if (messages.length === 0) {
    return <p className="py-8 text-center text-muted-foreground">Nenhuma mensagem enviada ainda.</p>
  }

  return (
    <div className="space-y-4">
      {/* Filtros */}
      <div className="flex flex-col gap-4 sm:flex-row">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Buscar por telefone ou template..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-full sm:w-[180px]">
            <SelectValue placeholder="Filtrar por status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">Todos</SelectItem>
            <SelectItem value="pending">Pendente</SelectItem>
            <SelectItem value="sent">Enviado</SelectItem>
            <SelectItem value="delivered">Entregue</SelectItem>
            <SelectItem value="read">Lido</SelectItem>
            <SelectItem value="failed">Falhou</SelectItem>
          </SelectContent>
        </Select>
        <Button variant="outline" onClick={handleRefresh} disabled={refreshing}>
          <RefreshCw className={`mr-2 h-4 w-4 ${refreshing ? "animate-spin" : ""}`} />
          Atualizar
        </Button>
      </div>

      {/* Tabela */}
      <div className="overflow-x-auto rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Telefone</TableHead>
              <TableHead className="hidden sm:table-cell">Template</TableHead>
              <TableHead>Status</TableHead>
              <TableHead className="hidden md:table-cell">Enviado</TableHead>
              <TableHead className="hidden lg:table-cell">Atualizado</TableHead>
              <TableHead className="w-[100px]">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredMessages.map((message) => {
              const status = statusConfig[message.status] || statusConfig.pending
              return (
                <TableRow key={message.id}>
                  <TableCell className="font-mono text-sm">{message.recipient_phone}</TableCell>
                  <TableCell className="hidden sm:table-cell">{message.template_name}</TableCell>
                  <TableCell>
                    <Badge variant={status.variant} className="gap-1">
                      {status.icon}
                      {status.label}
                    </Badge>
                  </TableCell>
                  <TableCell className="hidden md:table-cell text-muted-foreground text-sm">
                    {formatDistanceToNow(new Date(message.created_at), {
                      addSuffix: true,
                      locale: ptBR,
                    })}
                  </TableCell>
                  <TableCell className="hidden lg:table-cell text-muted-foreground text-sm">
                    {message.status_updated_at
                      ? formatDistanceToNow(new Date(message.status_updated_at), {
                          addSuffix: true,
                          locale: ptBR,
                        })
                      : "-"}
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm" onClick={() => handleViewHistory(message)}>
                      <History className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              )
            })}
          </TableBody>
        </Table>
      </div>

      <p className="text-sm text-muted-foreground">
        Mostrando {filteredMessages.length} de {messages.length} mensagens
      </p>

      {/* Dialog de Histórico */}
      <Dialog open={!!selectedMessage} onOpenChange={() => setSelectedMessage(null)}>
        <DialogContent className="max-w-lg max-h-[90vh]">
          <DialogHeader>
            <DialogTitle>Detalhes da Mensagem</DialogTitle>
          </DialogHeader>

          <ScrollArea className="max-h-[70vh] pr-4">
            {selectedMessage && (
              <div className="space-y-4">
                {/* Informações da Mensagem */}
                <Card>
                  <CardContent className="p-4 space-y-3">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <p className="text-xs text-muted-foreground">Telefone</p>
                        <p className="font-mono text-sm">{selectedMessage.recipient_phone}</p>
                      </div>
                      <div>
                        <p className="text-xs text-muted-foreground">Template</p>
                        <p className="text-sm">{selectedMessage.template_name}</p>
                      </div>
                      <div>
                        <p className="text-xs text-muted-foreground">Status Atual</p>
                        <Badge
                          variant={statusConfig[selectedMessage.status]?.variant || "secondary"}
                          className="mt-1 gap-1"
                        >
                          {statusConfig[selectedMessage.status]?.icon}
                          {statusConfig[selectedMessage.status]?.label || selectedMessage.status}
                        </Badge>
                      </div>
                      <div>
                        <p className="text-xs text-muted-foreground">Enviado em</p>
                        <p className="text-sm">
                          {format(new Date(selectedMessage.created_at), "dd/MM/yyyy HH:mm", { locale: ptBR })}
                        </p>
                      </div>
                    </div>
                    {selectedMessage.whatsapp_message_id && (
                      <div>
                        <p className="text-xs text-muted-foreground">ID WhatsApp</p>
                        <p className="font-mono text-xs break-all">{selectedMessage.whatsapp_message_id}</p>
                      </div>
                    )}
                  </CardContent>
                </Card>

                {/* Histórico de Status */}
                <div>
                  <h4 className="font-medium mb-2 flex items-center gap-2">
                    <History className="h-4 w-4" />
                    Histórico de Status
                  </h4>

                  {loadingHistory ? (
                    <div className="flex items-center justify-center py-8">
                      <RefreshCw className="h-5 w-5 animate-spin text-muted-foreground" />
                    </div>
                  ) : statusHistory.length === 0 ? (
                    <Card>
                      <CardContent className="py-6 text-center text-muted-foreground text-sm">
                        Nenhuma atualização de status recebida ainda.
                      </CardContent>
                    </Card>
                  ) : (
                    <div className="space-y-2">
                      {statusHistory.map((history, index) => {
                        const config = statusConfig[history.status] || statusConfig.pending
                        return (
                          <Card key={history.id}>
                            <CardContent className="p-3 flex items-center gap-3">
                              <div className={`${config.color}`}>{config.icon}</div>
                              <div className="flex-1">
                                <p className="font-medium text-sm">{config.label}</p>
                                <p className="text-xs text-muted-foreground">
                                  {format(new Date(history.timestamp), "dd/MM/yyyy HH:mm:ss", { locale: ptBR })}
                                </p>
                              </div>
                              {index === statusHistory.length - 1 && (
                                <Badge variant="outline" className="text-xs">
                                  Atual
                                </Badge>
                              )}
                            </CardContent>
                          </Card>
                        )
                      })}
                    </div>
                  )}
                </div>
              </div>
            )}
          </ScrollArea>
        </DialogContent>
      </Dialog>
    </div>
  )
}
