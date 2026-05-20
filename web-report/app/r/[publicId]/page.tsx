import { notFound } from "next/navigation";
import { isConfigured, supabasePublic } from "../../../lib/supabase";

type Params = Promise<{ publicId: string }>;

interface ReportRow {
  id: string;
  title: string;
  expires_at: string | null;
  visibility: string;
}

interface SnapshotData {
  captured_at?: string;
  period_days?: number;
  totals?: {
    followers?: number | null;
    impressions?: number | null;
    reach?: number | null;
    posts?: number | null;
  };
  accounts?: Array<{
    account_id: string;
    platform?: string;
    display_name?: string;
    followers?: number | null;
    impressions?: number | null;
    reach?: number | null;
    posts?: number | null;
  }>;
}

async function loadReport(publicId: string): Promise<{
  report: ReportRow;
  data: SnapshotData;
} | null> {
  if (!isConfigured) return null;

  const { data: report } = await supabasePublic
    .from("reports")
    .select("id, title, expires_at, visibility")
    .eq("public_id", publicId)
    .eq("visibility", "public")
    .maybeSingle();
  if (!report) return null;
  if (report.expires_at && new Date(report.expires_at) < new Date()) {
    return null;
  }

  const { data: snapshot } = await supabasePublic
    .from("report_snapshots")
    .select("data")
    .eq("report_id", report.id)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  return {
    report: report as ReportRow,
    data: (snapshot?.data as SnapshotData) ?? {},
  };
}

function formatNumber(n: number | null | undefined): string {
  if (n == null) return "—";
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
  return n.toString();
}

export default async function ReportPage({ params }: { params: Params }) {
  const { publicId } = await params;
  const loaded = await loadReport(publicId);
  if (!loaded) return notFound();

  const { report, data } = loaded;
  const periodDays = data.period_days ?? 30;
  const totals = data.totals ?? {};
  const accounts = data.accounts ?? [];
  const kpis: Array<{ label: string; value: number | null | undefined }> = [
    { label: "Total followers", value: totals.followers },
    { label: "Total impressions", value: totals.impressions },
    { label: "Total reach", value: totals.reach },
    { label: "Total posts", value: totals.posts },
  ];

  return (
    <main style={styles.page}>
      <header style={styles.header}>
        <h1 style={styles.title}>{report.title}</h1>
        <p style={styles.subtitle}>Last {periodDays} days</p>
      </header>
      <section style={styles.grid}>
        {kpis.map((k) => (
          <div key={k.label} style={styles.card}>
            <div style={styles.cardLabel}>{k.label}</div>
            <div style={styles.cardValue}>{formatNumber(k.value)}</div>
          </div>
        ))}
      </section>
      {accounts.length > 0 && (
        <section style={styles.accountsSection}>
          <h2 style={styles.h2}>Per account</h2>
          {accounts.map((a) => (
            <div key={a.account_id} style={styles.accountRow}>
              <div>
                <div style={styles.accountName}>
                  {a.display_name ?? a.platform ?? "—"}
                </div>
                <div style={styles.accountPlatform}>{a.platform ?? ""}</div>
              </div>
              <div style={styles.accountFollowers}>
                {formatNumber(a.followers ?? null)}
              </div>
            </div>
          ))}
        </section>
      )}
      <footer style={styles.footer}>
        Powered by{" "}
        <a href="https://reports.artifact.studio" style={styles.footerLink}>
          Artifact Reports
        </a>
      </footer>
    </main>
  );
}

const styles: Record<string, React.CSSProperties> = {
  page: {
    minHeight: "100vh",
    background: "#0B0B0E",
    color: "#FFFFFF",
    fontFamily:
      "-apple-system, BlinkMacSystemFont, 'SF Pro Text', system-ui, sans-serif",
    padding: "32px 24px 48px",
    maxWidth: 720,
    margin: "0 auto",
  },
  header: { marginBottom: 24 },
  title: { margin: 0, fontSize: 32, fontWeight: 700 },
  subtitle: { margin: "4px 0 0", color: "#A1A1AA", fontSize: 13 },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(2, 1fr)",
    gap: 12,
    marginBottom: 32,
  },
  card: {
    background: "#1A1A1F",
    borderRadius: 28,
    padding: 20,
    minHeight: 96,
    display: "flex",
    flexDirection: "column",
    justifyContent: "space-between",
  },
  cardLabel: { color: "#A1A1AA", fontSize: 12, fontWeight: 500 },
  cardValue: { fontSize: 40, fontWeight: 700, lineHeight: 1 },
  accountsSection: { marginBottom: 32 },
  h2: { margin: "0 0 12px", fontSize: 17, fontWeight: 600 },
  accountRow: {
    background: "#1A1A1F",
    borderRadius: 20,
    padding: "12px 16px",
    marginBottom: 8,
    display: "flex",
    alignItems: "center",
    justifyContent: "space-between",
  },
  accountName: { fontSize: 15, fontWeight: 500 },
  accountPlatform: { color: "#A1A1AA", fontSize: 12, marginTop: 2 },
  accountFollowers: { fontSize: 17, fontWeight: 600 },
  footer: { color: "#71717A", fontSize: 12, textAlign: "center" },
  footerLink: { color: "#A855F7", textDecoration: "none" },
};
