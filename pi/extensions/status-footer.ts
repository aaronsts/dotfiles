import { basename } from "node:path";

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

function formatTokens(tokens: number): string {
	if (tokens < 1_000) return `${tokens}`;
	if (tokens < 1_000_000) return `${(tokens / 1_000).toFixed(1)}k`;
	return `${(tokens / 1_000_000).toFixed(2)}m`;
}

function color(code: number, text: string): string {
	return `\u001B[${code}m${text}\u001B[39m`;
}

function contextLabel(ctx: ExtensionContext): string {
	const usage = ctx.getContextUsage();
	const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;

	if (!usage || usage.tokens === null || !contextWindow) return "ctx —";

	return `ctx ${formatTokens(usage.tokens)}/${formatTokens(contextWindow)} (${Math.round(usage.percent ?? 0)}%)`;
}

function costLabel(ctx: ExtensionContext): string {
	const cost = ctx.sessionManager.getBranch().reduce((total, entry) => {
		if (entry.type !== "message" || entry.message.role !== "assistant") return total;
		return total + (entry.message as AssistantMessage).usage.cost.total;
	}, 0);

	return `cost $${cost.toFixed(4)}`;
}

export default function (pi: ExtensionAPI) {
	let refresh = () => {};

	pi.on("turn_end", () => refresh());
	pi.on("model_select", () => refresh());
	pi.on("thinking_level_select", () => refresh());

	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			refresh = () => tui.requestRender();
			const unsubscribeBranch = footerData.onBranchChange(refresh);

			return {
				dispose: unsubscribeBranch,
				invalidate() {},
				render(width: number): string[] {
					const folder = basename(ctx.cwd) || ctx.cwd;
					const branch = footerData.getGitBranch() ?? "no branch";
					const model = ctx.model?.id ?? "no model";
					const effort = ctx.thinkingLevel ?? "off";
					const separator = theme.fg("dim", "  |  ");
					const line = [
						color(36, folder),
						color(35, branch),
						color(33, contextLabel(ctx)),
						color(32, costLabel(ctx)),
						theme.fg("dim", "5h —"),
						theme.fg("dim", "week —"),
						color(34, `${model} / ${effort}`),
					].join(separator);

					return [truncateToWidth(line, width)];
				},
			};
		});
	});
}
