import { useMemo, useState } from "react";
import {
  DEFAULT_BASE_CONFIG,
  TEMPLATE_DEFAULTS,
  TEMPLATE_LABELS,
  type TemplateKind,
} from "@shared/constants/templates";
import { createPool, deployTemplate, runDemoSwaps, type FlowStep } from "./lib/onchain";

function stringifyDefaults(template: TemplateKind): string {
  const payload = {
    base: DEFAULT_BASE_CONFIG,
    ...TEMPLATE_DEFAULTS[template],
  };

  return JSON.stringify(payload, (_, value) => (typeof value === "bigint" ? value.toString() : value), 2);
}

function parseConfig(raw: string): unknown {
  return JSON.parse(raw, (_, value) => {
    if (typeof value === "string" && /^\d+$/.test(value) && value.length > 15) {
      return BigInt(value);
    }
    return value;
  });
}

export default function App() {
  const [template, setTemplate] = useState<TemplateKind>("stablecoin");
  const [configText, setConfigText] = useState<string>(stringifyDefaults("stablecoin"));
  const [logs, setLogs] = useState<FlowStep[]>([]);
  const [isBusy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const templateOptions = useMemo(
    () => (Object.keys(TEMPLATE_LABELS) as TemplateKind[]).map((key) => ({ key, label: TEMPLATE_LABELS[key] })),
    [],
  );

  function appendLogs(next: FlowStep[]) {
    setLogs((prev) => [...next, ...prev]);
  }

  async function handleDeploy() {
    setBusy(true);
    setError(null);

    try {
      const config = parseConfig(configText);
      const result = await deployTemplate(template, config);
      appendLogs(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to deploy template");
    } finally {
      setBusy(false);
    }
  }

  async function handleCreatePool() {
    setBusy(true);
    setError(null);

    try {
      appendLogs(await createPool(template));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create pool");
    } finally {
      setBusy(false);
    }
  }

  async function handleRunDemo() {
    setBusy(true);
    setError(null);

    try {
      appendLogs(await runDemoSwaps(template));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to run demo swaps");
    } finally {
      setBusy(false);
    }
  }

  function onTemplateChange(next: TemplateKind) {
    setTemplate(next);
    setConfigText(stringifyDefaults(next));
    setError(null);
  }

  return (
    <main className="app-shell">
      <section className="panel hero">
        <p className="eyebrow">Uniswap v4 Hook Templates</p>
        <h1>Specialized Market Launcher</h1>
        <p>
          Configure a market-specific hook template, deploy with deterministic salts, initialize pool workflows, and
          execute guided swap demos.
        </p>
      </section>

      <section className="panel controls">
        <div className="control-row">
          <label htmlFor="template">Template</label>
          <select
            id="template"
            value={template}
            onChange={(event) => onTemplateChange(event.target.value as TemplateKind)}
          >
            {templateOptions.map((option) => (
              <option key={option.key} value={option.key}>
                {option.label}
              </option>
            ))}
          </select>
        </div>

        <div className="control-row">
          <label htmlFor="config">Config JSON</label>
          <textarea
            id="config"
            value={configText}
            onChange={(event) => setConfigText(event.target.value)}
            rows={16}
            spellCheck={false}
          />
        </div>

        <div className="action-row">
          <button disabled={isBusy} onClick={handleDeploy}>
            1. Deploy Template
          </button>
          <button disabled={isBusy} onClick={handleCreatePool}>
            2. Create Pool
          </button>
          <button disabled={isBusy} onClick={handleRunDemo}>
            3. Run Demo Swaps
          </button>
        </div>

        {error ? <p className="error">{error}</p> : null}
      </section>

      <section className="panel telemetry">
        <h2>Execution Feed</h2>
        {logs.length === 0 ? <p className="muted">No transactions yet.</p> : null}
        <ul>
          {logs.map((entry, index) => (
            <li key={`${entry.hash}-${index}`}>
              <p>
                <strong>{entry.step}</strong>
                <span className={`status status-${entry.status}`}>{entry.status}</span>
              </p>
              <code>{entry.hash}</code>
              {entry.explorerUrl ? (
                <a href={entry.explorerUrl} target="_blank" rel="noreferrer">
                  Explorer
                </a>
              ) : null}
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}
