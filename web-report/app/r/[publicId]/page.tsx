import { notFound } from "next/navigation";
import { isConfigured, supabasePublic } from "../../../lib/supabase";

type Params = Promise<{ publicId: string }>;

interface Report {
  id: string;
  workspace_id: string;
  title: string;
  config: { period_days?: number } | null;
  expires_at: string | null;
}

interface Snapshot {
  social_account_id: string;
  captured_at: string;
  followers: number | null;
  impressions: number | null;
  reach: number | null;
  posts: number | null;
}

async function loadReport(publicId: string): Promise<{
  report: Report;
  totals: { followers: number | null; impressions: number | null; reach: number | null; posts: number | null };
} | null> {
  if (!isConfigured) return null;

  const { data: report } = await supabasePublic
    .from("reports")
    .select("id, workspace_id, title, config, expires_at, visibility")
    .eq("public_id", publicId)
    .eq("visibility", "public")
    .maybeSingle();
  if (!report) return null;
  if (report.expires_at && new Date(report.expires_at) < new Date()) {
    return null;
  }

  // Pull every snapshot for the workspace's social accounts. RLS lets
  // anon see them because the parent report is public — the join here
  // happens via social_accounts.workspace_id.
  const { data: accounts } = await supabasePublic
    .from("social_accounts")
    .select("id")
    .eq("workspace_id", report.workspace_id);
  const accountIds = (accounts ?? []).map((a) => a.id as string);

  let totals = {
    followers: null as number | null,
    impressions: null as number | null,
    reach: null as number | null,
    posts: null as number | null,
  };
  if (accountIds.length > 0) {
    const { data: snaps } = await supabasePublic
      .from("metrics_snapshots")
      .select("social_account_id, captured_at, followers, impressions, reach, posts")
      .in("social_account_id", accountIds)
      .order("captured_at", { ascending: false });
    const latestPerAccount = new Map<string, Snapshot>();
    for (const s of (snaps ?? []) as Snapshot[]) {
      if (!latestPerAccount.has(s.social_account_id)) {
        latestPerAccount.set(s.social_account_id, s);
      }
    }
    const agg = (pick: (s: Snapshot) => number | null) => {
      let sum = 0;
      let any = false;
      for (const s of latestPerAccount.values()) {
        const v = pick(s);
        if (v != null) {
          sum += v;
          any = true;
        }
      }
      return any ? sum : null;
    };
    totals = {
      followers: agg((s) => s.followers),
      impressions: agg((s) => s.impressions),
      reach: agg((s) => s.reach),
      posts: agg((s) => s.posts),
    };
  }

  return { report: report as Report, totals };
}

function formatNumber(n: number | null): string {
  if (n == null) return "—";
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`;
  return n.toString();
}

export default async function ReportPage({ params }: { params: Params }) {
  const { publicId } = await params;
  const data = await loadReport(publicId);
  if (!data) return notFound();

  const { report, totals } = data;
  const periodDays = report.config?.period_days ?? 30;
  const kpis: Array<{ label: string; value: number | null }> = [
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
  footer: { color: "#71717A", fontSize: 12, textAlign: "center" },
  footerLink: { color: "#A855F7", textDecoration: "none" },
};
