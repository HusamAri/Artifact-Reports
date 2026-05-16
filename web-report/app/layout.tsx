import type { ReactNode } from "react";

export const metadata = {
  title: "Artifact Reports",
  description: "Shared social media analytics report.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
