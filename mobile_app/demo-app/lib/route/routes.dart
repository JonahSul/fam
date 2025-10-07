import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:henox/helpers/services/auth_service.dart';
import 'package:henox/route/route_method.dart';
import 'package:henox/view/apps/calendar_screen.dart';
import 'package:henox/view/apps/chat_screen.dart';
import 'package:henox/view/apps/email/inbox_screen.dart';
import 'package:henox/view/apps/email/read_email_screen.dart';
import 'package:henox/view/apps/file_manager_screen.dart';
import 'package:henox/view/apps/kanban/kanban_bord_screen.dart';
import 'package:henox/view/apps/task/task_detail_screen.dart';
import 'package:henox/view/apps/task/task_list_screen.dart';
import 'package:henox/view/auth/confirm_mail_screen.dart';
import 'package:henox/view/auth/forgot_password_screen.dart';
import 'package:henox/view/auth/lock_screen.dart';
import 'package:henox/view/auth/log_out_screen.dart';
import 'package:henox/view/auth/login_screen.dart';
import 'package:henox/view/auth/register_account_screen.dart';
import 'package:henox/view/components/base_ui/accordion_screen.dart';
import 'package:henox/view/components/base_ui/alert_screen.dart';
import 'package:henox/view/components/base_ui/avatars_screen.dart';
import 'package:henox/view/components/base_ui/badges_screen.dart';
import 'package:henox/view/components/base_ui/breadcrumb_screen.dart';
import 'package:henox/view/components/base_ui/buttons_screen.dart';
import 'package:henox/view/components/base_ui/card_screen.dart';
import 'package:henox/view/components/base_ui/carousel_screen.dart';
import 'package:henox/view/components/base_ui/collapse_screen.dart';
import 'package:henox/view/components/base_ui/dropdowns_screen.dart';
import 'package:henox/view/components/base_ui/embed_video_screen.dart';
import 'package:henox/view/components/base_ui/links_screen.dart';
import 'package:henox/view/components/base_ui/list_group_screen.dart';
import 'package:henox/view/components/base_ui/modals_screen.dart';
import 'package:henox/view/components/base_ui/notification_screen.dart';
import 'package:henox/view/components/base_ui/pagination_screen.dart';
import 'package:henox/view/components/base_ui/placeholders_screen.dart';
import 'package:henox/view/components/base_ui/progress_screen.dart';
import 'package:henox/view/components/base_ui/spinners_screen.dart';
import 'package:henox/view/components/base_ui/tab_screen.dart';
import 'package:henox/view/components/base_ui/tool_tip_screen.dart';
import 'package:henox/view/components/base_ui/typography_screen.dart';
import 'package:henox/view/components/base_ui/utilities_screen.dart';
import 'package:henox/view/components/chart_screen.dart';
import 'package:henox/view/components/extended_ui/dragula_screen.dart';
import 'package:henox/view/components/extended_ui/range_slider_screen.dart';
import 'package:henox/view/components/extended_ui/rating_bar_screen.dart';
import 'package:henox/view/components/extended_ui/scroll_bar_screen.dart';
import 'package:henox/view/components/forms/basic_element_screen.dart';
import 'package:henox/view/components/forms/editor_screen.dart';
import 'package:henox/view/components/forms/file_upload_screen.dart';
import 'package:henox/view/components/forms/validation_screen.dart';
import 'package:henox/view/components/forms/wizard_screen.dart';
import 'package:henox/view/components/icons_screen.dart';
import 'package:henox/view/components/map_screen.dart';
import 'package:henox/view/components/tables/basic_table_screen.dart';
import 'package:henox/view/components/widgets_screen.dart';
import 'package:henox/view/dashboard/dashboard_screen.dart';
import 'package:henox/view/dashboard/second_dashboard_screen.dart';
import 'package:henox/view/error/error_404.dart';
import 'package:henox/view/error/error_404_alt_screen.dart';
import 'package:henox/view/error/error_500_screen.dart';
import 'package:henox/view/ui/faqs_screen.dart';
import 'package:henox/view/ui/invoice_screen.dart';
import 'package:henox/view/ui/maintenance_screen.dart';
import 'package:henox/view/ui/pricing_screen.dart';
import 'package:henox/view/ui/profile_screen.dart';
import 'package:henox/view/ui/starter_pages.dart';
import 'package:henox/view/ui/timeline_screen.dart';
import 'package:henox/view/ui/with_preloader_screen.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return AuthService.isLoggedIn ? null : RouteSettings(name: '/auth/login');
  }
}

List<GetPage> getPageRoute() => [
      GetPage(name: route.login, page: () => LoginScreen()),
      GetPage(name: route.forgotPassword, page: () => ForgotPasswordScreen()),
      GetPage(name: route.createAccount, page: () => RegisterAccountScreen()),
      GetPage(name: route.logOut, page: () => LogOutScreen()),
      GetPage(name: route.lock, page: () => LockScreen()),
      GetPage(name: route.confirmMail, page: () => ConfirmMailScreen()),
      _authMiddleware('/', () => DashboardScreen()),
      _authMiddleware(route.dashboard, () => DashboardScreen()),
      _authMiddleware(route.dashboard2, () => SecondDashboardScreen()),
      _authMiddleware(route.calendar, () => CalendarScreen()),
      _authMiddleware(route.chat, () => ChatScreen()),
      _authMiddleware(route.calendar, () => CalendarScreen()),
      _authMiddleware(route.emailInbox, () => InboxScreen()),
      _authMiddleware(route.readEmail, () => ReadEmailScreen()),
      _authMiddleware(route.taskList, () => TaskListScreen()),
      _authMiddleware(route.taskDetail, () => TaskDetailScreen()),
      _authMiddleware(route.kanbanBoard, () => KanbanBoardScreen()),
      _authMiddleware(route.profile, () => ProfileScreen()),
      _authMiddleware(route.faqs, () => FaqsScreen()),
      _authMiddleware(route.fileManager, () => FileManagerScreen()),
      _authMiddleware(route.pricing, () => PricingScreen()),
      _authMiddleware(route.maintenance, () => MaintenanceScreen()),
      _authMiddleware(route.starterPage, () => StarterPages()),
      _authMiddleware(route.withPreloader, () => WithPreloaderScreen()),
      _authMiddleware(route.timeLine, () => TimeLineScreen()),
      _authMiddleware(route.invoice, () => InvoiceScreen()),
      _authMiddleware(route.accordion, () => AccordionScreen()),
      _authMiddleware(route.alert, () => AlertScreen()),
      _authMiddleware(route.avatars, () => AvatarsScreen()),
      _authMiddleware(route.badges, () => BadgesScreen()),
      _authMiddleware(route.breadcrumb, () => BreadcrumbScreen()),
      _authMiddleware(route.buttons, () => ButtonsScreen()),
      _authMiddleware(route.card, () => CardScreen()),
      _authMiddleware(route.carousel, () => CarouselScreen()),
      _authMiddleware(route.collapse, () => CollapseScreen()),
      _authMiddleware(route.dropdowns, () => DropdownsScreen()),
      _authMiddleware(route.embedVideo, () => EmbedVideoScreen()),
      _authMiddleware(route.links, () => LinksScreen()),
      _authMiddleware(route.listGroup, () => ListGroupScreen()),
      _authMiddleware(route.models, () => ModalsScreen()),
      _authMiddleware(route.notification, () => NotificationScreen()),
      _authMiddleware(route.placeholder, () => PlaceholdersScreen()),
      _authMiddleware(route.pagination, () => PaginationScreen()),
      _authMiddleware(route.progress, () => ProgressScreen()),
      _authMiddleware(route.spinners, () => SpinnersScreen()),
      _authMiddleware(route.tabBar, () => TabScreen()),
      _authMiddleware(route.tooltip, () => ToolTipScreen()),
      _authMiddleware(route.typography, () => TypographyScreen()),
      _authMiddleware(route.utilities, () => UtilitiesScreen()),
      _authMiddleware(route.dragula, () => DragulaScreen()),
      _authMiddleware(route.rangeSlider, () => RangeSliderScreen()),
      _authMiddleware(route.ratings, () => RatingBarScreen()),
      _authMiddleware(route.scrollbar, () => ScrollBarScreen()),
      _authMiddleware(route.basicTable, () => BasicTableScreen()),
      _authMiddleware(route.charts, () => ChartScreen()),
      _authMiddleware(route.basicElement, () => BasicElementScreen()),
      _authMiddleware(route.validation, () => ValidationScreen()),
      _authMiddleware(route.wizard, () => WizardScreen()),
      _authMiddleware(route.fileUpload, () => FileUploadScreen()),
      _authMiddleware(route.editor, () => EditorScreen()),
      _authMiddleware(route.map, () => MapScreen()),
      _authMiddleware(route.icon, () => IconsScreen()),
      _authMiddleware(route.widgets, () => WidgetsScreen()),
      _authMiddleware(route.error404, () => Error404Screen()),
      _authMiddleware(route.error404Alt, () => Error404AltScreen()),
      _authMiddleware(route.error500, () => Error500Screen()),
    ];

GetPage _authMiddleware(String name, Widget Function() page) => GetPage(
    name: name,
    page: page,
    middlewares: [AuthMiddleware()],
    transition: Transition.noTransition);
