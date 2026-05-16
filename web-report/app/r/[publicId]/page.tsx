type Params = Promise<{ publicId: string }>;

export default async function ReportPage({ params }: { params: Params }) {
  const { publicId } = await params;
  // TODO(M7): fetch report_snapshot via Supabase anon client (RLS policy:
  //   visibility='public' AND not expired) and render dashboard.
  return (
    <main style={{ padding: 24, fontFamily: "system-ui" }}>
      <h1>Report</h1>
      <p>
        Public ID: <code>{publicId}</code>
      </p>
      <p>M7 will render the dashboard here.</p>
    </main>
  );
}
