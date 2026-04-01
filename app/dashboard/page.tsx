import { createClient } from "@/lib/supabase/server"
import { redirect } from "next/navigation"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { MessageSquare, CheckCircle, Clock, AlertCircle } from "lucide-react"

export default async function DashboardPage() {
  const supabase = await createClient()

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()
  if (error || !user) {
    redirect("/auth/login")
  }

  // Get profile and tenant info
  const { data: profile } = await supabase.from("profiles").select("*, tenant:tenants(*)").eq("id", user.id).single()

  // Get message stats
  const { count: totalMessages } = await supabase.from("messages").select("*", { count: "exact", head: true })

  const { count: deliveredMessages } = await supabase
    .from("messages")
    .select("*", { count: "exact", head: true })
    .eq("status", "delivered")

  const { count: readMessages } = await supabase
    .from("messages")
    .select("*", { count: "exact", head: true })
    .eq("status", "read")

  const { count: failedMessages } = await supabase
    .from("messages")
    .select("*", { count: "exact", head: true })
    .eq("status", "failed")

  const stats = [
    {
      title: "Total de Mensagens",
      value: totalMessages || 0,
      icon: MessageSquare,
      color: "text-primary",
    },
    {
      title: "Entregues",
      value: deliveredMessages || 0,
      icon: CheckCircle,
      color: "text-green-500",
    },
    {
      title: "Lidas",
      value: readMessages || 0,
      icon: Clock,
      color: "text-blue-500",
    },
    {
      title: "Falharam",
      value: failedMessages || 0,
      icon: AlertCircle,
      color: "text-destructive",
    },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">
          Bem-vindo, {user.user_metadata?.full_name || user.email}
          {profile?.tenant?.name && ` - ${profile.tenant.name}`}
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.title}>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">{stat.title}</CardTitle>
              <stat.icon className={`h-4 w-4 ${stat.color}`} />
            </CardHeader>
            <CardContent>
              <p className="text-2xl font-bold">{stat.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {!profile?.tenant_id && (
        <Card className="border-amber-200 bg-amber-50 dark:border-amber-900 dark:bg-amber-950">
          <CardHeader>
            <CardTitle className="text-amber-800 dark:text-amber-200">Configure sua conta</CardTitle>
          </CardHeader>
          <CardContent className="text-amber-700 dark:text-amber-300">
            <p>
              Sua conta ainda não está vinculada a uma empresa. Entre em contato com o administrador para configurar seu
              acesso.
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
