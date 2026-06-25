export function PrivacyPolicyPage({ onBack }: { onBack: () => void }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep pb-12">
      <div className="px-4 pt-6">
        <div className="max-w-lg mx-auto">
          <button onClick={onBack}
            className="flex items-center gap-2 text-parchment-dim hover:text-parchment transition-colors mb-6 text-sm font-medium">
            ← Back
          </button>
          <h1 className="text-parchment text-2xl font-display font-bold mb-6">Privacy Policy</h1>
          <div className="space-y-6 text-parchment-dim text-sm leading-relaxed">
            <section>
              <h2 className="text-parchment font-display font-semibold text-base mb-2">What data we collect</h2>
              <p>We collect your email address, name, and quiz performance data to provide personalised learning recommendations.</p>
            </section>
            <section>
              <h2 className="text-parchment font-display font-semibold text-base mb-2">Children's data</h2>
              <p>Child profiles are created by parents. We store first names, year groups, target schools, and learning progress. We do not share this data with third parties.</p>
            </section>
            <section>
              <h2 className="text-parchment font-display font-semibold text-base mb-2">How we use data</h2>
              <p>Your data is used solely to personalise quiz content, track progress, and generate readiness reports for your child's exam preparation.</p>
            </section>
            <section>
              <h2 className="text-parchment font-display font-semibold text-base mb-2">Data retention</h2>
              <p>You may request deletion of your account and all associated data at any time by contacting us.</p>
            </section>
            <section>
              <h2 className="text-parchment font-display font-semibold text-base mb-2">Contact</h2>
              <p>For any privacy concerns, please contact our support team.</p>
            </section>
          </div>
        </div>
      </div>
    </div>
  );
}
