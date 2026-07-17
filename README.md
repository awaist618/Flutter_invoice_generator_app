# Invoicely - Professional Invoice Generator

Invoicely is a local-first, high-performance mobile application designed for freelancers and small business owners to manage, generate, and track invoices with ease. Built with Flutter, it offers a seamless and professional experience without the need for a backend.

## 📱 Screenshots

<div align="center">
  <img src="screenshots/dashboard.jpg" width="400" alt="Dashboard Screen"/>
  <img src="screenshots/create_invoice.jpg" width="400" alt="Create Invoice Screen"/>
  <br/>
  <img src="screenshots/invoice_detail.jpg" width="400" alt="Invoice Detail Screen"/>
  <img src="screenshots/reports.jpg" width="400" alt="Reports Screen"/>
  <br/>
  <img src="screenshots/settings.jpg" width="400" alt="Settings Screen"/>
</div>

## ✨ Features

- **Professional Dashboard**: Track total revenue, paid, and unpaid invoices at a glance.
- **Smart Reminders**: Receive professional notifications 24 hours and 1 hour before an invoice is due.
- **PDF Generation**: Create, print, and share professional PDF invoices with your company logo and details.
- **Customer Management**: Save customer details for quick invoice creation.
- **Product/Service Catalog**: Store your products and prices to add them to invoices in seconds.
- **Financial Analytics**: Visualize income trends and revenue growth with interactive charts.
- **Local-First Privacy**: All your data is stored securely on your device. No cloud tracking.
- **Dark Mode**: Beautifully crafted dark theme for comfortable use in any lighting.
- **Delete Management**: Easy long-press gesture to manage and delete generated invoices.

## 📦 Packages Used

- `provider`: State management for a reactive user interface.
- `fl_chart`: For rendering interactive financial reports and trends.
- `pdf` & `printing`: Powering the document generation engine.
- `flutter_local_notifications`: Managing the professional reminder system.
- `shared_preferences`: Persistent local storage for invoices and settings.
- `intl`: Precise date and currency formatting for global use.
- `share_plus`: Enabling seamless sharing of generated documents.
- `url_launcher`: Connecting with the developer and external resources.
- `font_awesome_flutter`: Enhancing the UI with professional brand icons.
- `uuid`: Generating unique identifiers for every transaction.

## 🚀 Setup Instructions

Follow these steps to get the project running on your local machine:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/awaist618/invoice_generator_app.git
    ```

2.  **Navigate to the project directory**:
    ```bash
    cd invoice_generator_app
    ```

3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

4.  **Generate app icons** (Optional):
    ```bash
    dart run flutter_launcher_icons
    ```

5.  **Run the application**:
    ```bash
    flutter run
    ```

6.  **Build Release APK**:
    ```bash
    flutter build apk --release --split-per-abi
    ```

---
Developed with ❤️ by **Awais Tariq**
