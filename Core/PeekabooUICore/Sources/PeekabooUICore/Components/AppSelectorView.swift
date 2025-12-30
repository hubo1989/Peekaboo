//
//  AppSelectorView.swift
//  PeekabooUICore
//
//  Application selection UI component
//

import AppKit
import Observation
import SwiftUI

public struct AppSelectorView: View {
    @Bindable private var overlayManager: OverlayManager

    public init(overlayManager: OverlayManager) {
        self._overlayManager = Bindable(overlayManager)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(localized: "Target Applications"))
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Menu(String(localized: "Detail Level")) {
                    Button(String(localized: "Essential (Buttons & Inputs)")) {
                        self.overlayManager.setDetailLevel(.essential)
                    }
                    .disabled(self.overlayManager.detailLevel == .essential)

                    Button(String(localized: "Moderate (Include Lists & Tables)")) {
                        self.overlayManager.setDetailLevel(.moderate)
                    }
                    .disabled(self.overlayManager.detailLevel == .moderate)

                    Button(String(localized: "All (Show Everything)")) {
                        self.overlayManager.setDetailLevel(.all)
                    }
                    .disabled(self.overlayManager.detailLevel == .all)
                }
                .menuStyle(.borderlessButton)
                .padding(.trailing, 8)

                Menu {
                    Button(String(localized: "All Applications")) {
                        self.overlayManager.setAppSelectionMode(.all)
                    }
                    .disabled(self.overlayManager.selectedAppMode == .all)

                    Divider()

                    ForEach(self.overlayManager.applications) { app in
                        Button(action: {
                            self.overlayManager.setAppSelectionMode(.single, bundleID: app.bundleIdentifier)
                        }, label: {
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                Text(app.name)
                            }
                        })
                        .disabled(self.overlayManager.selectedAppMode == .single &&
                            self.overlayManager.selectedAppBundleID == app.bundleIdentifier)
                    }
                } label: {
                    HStack {
                        if self.overlayManager.selectedAppMode == .all {
                            Image(systemName: "apps.iphone")
                            Text(String(localized: "All Applications"))
                        } else if let selectedID = overlayManager.selectedAppBundleID,
                                  let app = overlayManager.applications
                                      .first(where: { $0.bundleIdentifier == selectedID })
                        {
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            Text(app.name)
                        }
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                }
                .menuStyle(.borderlessButton)
            }

            if self.overlayManager.selectedAppMode == .single {
                Text(String(localized: "Inspecting single application"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(String(localized: "Inspecting all running applications"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}