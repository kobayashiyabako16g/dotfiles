import type {
  ContextBuilder,
  ExtOptions,
  Plugin,
  ProtocolName,
} from "jsr:@shougo/dpp-vim@~4.5.0/types";
import type { Protocol } from "jsr:@shougo/dpp-vim@~4.5.0/protocol";
import type { Dpp } from "jsr:@shougo/dpp-vim@~4.5.0/dpp";
import { mergeFtplugins } from "jsr:@shougo/dpp-vim@~4.5.0/utils";
import {
  BaseConfig,
  type ConfigReturn,
  type MultipleHook,
} from "jsr:@shougo/dpp-vim@~4.5.0/config";
import type {
  Ext as TomlExt,
  Params as TomlParams,
} from "jsr:@shougo/dpp-ext-toml@~1.3.0";
import type {
  Ext as LazyExt,
  LazyMakeStateResult,
  Params as LazyParams,
} from "jsr:@shougo/dpp-ext-lazy@~1.5.0";
import type {
  Ext as LocalExt,
  Params as LocalParams,
} from "jsr:@shougo/dpp-ext-local@~1.3.0";

import type { Denops } from "jsr:@denops/std@~7.6.0";

console.log("dpp.ts is loaded!");
const BASE_PATH = Deno.env.get("HOME") + "/.config/nvim";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<ConfigReturn> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    const [context, options] = await args.contextBuilder.get(args.denops);
    const protocols = await args.denops.dispatcher.getProtocols() as Record<
      string,
      Protocol
    >;

    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];
    let multipleHooks: MultipleHook[] = [];

    // Load toml plugins
    const [tomlExt, tomlOptions, tomlParams]: [
      TomlExt | undefined,
      ExtOptions,
      TomlParams,
    ] = await args.denops.dispatcher.getExt(
      "toml",
    ) as [TomlExt | undefined, ExtOptions, TomlParams];
    if (tomlExt) {
      const action = tomlExt.actions.load;

      const tomlPromises = [
        { path: `${BASE_PATH}/dpp.toml`, lazy: false },
        { path: `${BASE_PATH}/dpp_lsp.toml`, lazy: true },
        { path: `${BASE_PATH}/dpp_lazy.toml`, lazy: true },
      ].map((tomlFile) =>
        action.callback({
          denops: args.denops,
          context,
          options,
          protocols,
          extOptions: tomlOptions,
          extParams: tomlParams,
          actionParams: {
            path: tomlFile.path,
            options: {
              lazy: tomlFile.lazy,
            },
          },
        })
      );

      const tomls = await Promise.all(tomlPromises);

      // Merge toml results
      for (const toml of tomls) {
        for (const plugin of toml.plugins ?? []) {
          recordPlugins[plugin.name] = plugin;
        }

        if (toml.ftplugins) {
          mergeFtplugins(ftplugins, toml.ftplugins);
        }

        if (toml.multiple_hooks) {
          multipleHooks = multipleHooks.concat(toml.multiple_hooks);
        }

        if (toml.hooks_file) {
          hooksFiles.push(toml.hooks_file);
        }
      }
    }

    const [localExt, localOptions, localParams]: [
      LocalExt | undefined,
      ExtOptions,
      LocalParams,
    ] = await args.denops.dispatcher.getExt(
      "local",
    ) as [LocalExt | undefined, ExtOptions, LocalParams];
    if (localExt) {
      const action = localExt.actions.local;

      const localPlugins = await action.callback({
        denops: args.denops,
        context,
        options,
        protocols,
        extOptions: localOptions,
        extParams: localParams,
        actionParams: {
          directory: `${BASE_PATH}/local/plugins`,
          options: {
            frozen: true,
            merged: false,
          },
        },
      });

      for (const plugin of localPlugins) {
        if (plugin.name in recordPlugins) {
          recordPlugins[plugin.name] = Object.assign(
            recordPlugins[plugin.name],
            plugin,
          );
        } else {
          recordPlugins[plugin.name] = plugin;
        }
      }
    }

    const [lazyExt, lazyOptions, lazyParams]: [
      LazyExt | undefined,
      ExtOptions,
      LazyParams,
    ] = await args.denops.dispatcher.getExt(
      "lazy",
    ) as [LazyExt | undefined, ExtOptions, LazyParams];
    let lazyResult: LazyMakeStateResult | undefined = undefined;
    if (lazyExt) {
      const action = lazyExt.actions.makeState;

      lazyResult = await action.callback({
        denops: args.denops,
        context,
        options,
        protocols,
        extOptions: lazyOptions,
        extParams: lazyParams,
        actionParams: {
          plugins: Object.values(recordPlugins),
        },
      });
    }

    return {
      ftplugins,
      hooksFiles,
      multipleHooks,
      plugins: lazyResult?.plugins ?? [],
      stateLines: lazyResult?.stateLines ?? [],
    };
  }
}
