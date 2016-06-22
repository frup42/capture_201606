public class Application
{
	public static fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory(new Map<Type, Type>{
		IDiscoService.class => DiscoService.class
	});
}