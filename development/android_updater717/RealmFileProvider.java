package com.avenor.realmupdater;

import androidx.core.content.FileProvider;

/** Separate scoped updater provider, avoids overriding Godot's built-in provider. */
public final class RealmFileProvider extends FileProvider {
    public RealmFileProvider() { super(); }
}
