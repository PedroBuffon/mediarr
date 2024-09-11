# Sonarr Anime Configuration Guide

This guide will help you set up Sonarr with a dedicated root folder, series type, and download client specifically for anime. Follow the steps below to streamline your anime downloads.

## Step 1: Create a Root Folder for Anime

1. Open **Sonarr** and go to **Settings** > **Media Management**.
2. Under the **Root Folders** section, click **Add Another Root Folder**.
3. Create a new folder for your anime, for example:
/Disk/anime
4. Save your changes.

## Step 2: Set Up Anime Tag

1. Navigate to **Settings** > **Tags**.
2. Create a new tag and name it `anime`.
3. Go to **Settings** > **Profiles** and click **Add Auto Tag**.
4. Name this tag `anime` and set the tag to `anime`.
5. In the Auto Tag settings:

- Select the **Root Folder** you created for anime.
- Set the **Series Type** to **Anime**.

6. Save your changes.

## Step 3: Configure qBittorrent for Anime Downloads

1. Go to **Settings** > **Download Clients**.
2. Add **qBittorrent** a second time with the following settings:

- **Name**: qBit Anime (or any name you prefer).
- **Tag**: Set the tag to `anime`.
- **Category**: Set the category to `anime` (or match the category name you use in qBittorrent).
- **Priority**: Set a higher priority than your default download client to ensure anime is downloaded first. (OPTIONAL)

3; Save your changes.

---

With this configuration, Sonarr will now handle anime downloads separately, placing them in their designated folder and prioritizing them using the qBittorrent client with the `anime` tag.

---

Feel free to adjust this guide to your preferred folder names and specific download client settings!
