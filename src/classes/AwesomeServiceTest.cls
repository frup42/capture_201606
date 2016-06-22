@isTest
private class AwesomeServiceTest
{
	private static final DateTime KNOWN_SATURDAY = Datetime.newInstance(2000, 1, 1);
	private static final DateTime KNOWN_SUNDAY = KNOWN_SATURDAY.addDays(1);

	@isTest
	private static void getDownSaturdayNight_getsDown_IfAppropriate()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IDiscoService mockDisco = new Mocks.DiscoService(mocks);
		Application.Service.setMock(IDiscoService.class, mockDisco);

		//Given
		User u = new User(
			FirstName = 'Duff',
			LastName = 'Man',
			LikesToParty__c = true,
			CantWaitForTheWeekend__c = true
		);
		
		//When
		AwesomeService.getDownSaturdayNight(u, KNOWN_SATURDAY);

		//Then
		((IDiscoService)mocks.verify(mockDisco)).getDown(u);
	}

	@isTest
	private static void getDownSaturdayNight_doesntGetDown_OnASchoolNight_WithCaptor()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IDiscoService mockDisco = new Mocks.DiscoService(mocks);
		Application.Service.setMock(IDiscoService.class, mockDisco);

		//Given
		User u = new User(
			FirstName = 'Buzz',
			LastName = 'Killington',
			LikesToParty__c = false,
			CantWaitForTheWeekend__c = false
		);
		
		//When
		AwesomeService.getDownSaturdayNight(u, KNOWN_SUNDAY);

		//Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(DiscoService.Event.class);
		((IDiscoService)mocks.verify(mockDisco)).notifyUser((DiscoService.Event)argument.capture());

		DiscoService.Event actual = (DiscoService.Event)argument.getValue();
		System.assertEquals(actual.EventTarget, u);
		System.assertEquals(actual.EventType, 'Uncool');
		System.assertEquals(actual.Message, 'It\'s hip to be a square');
	}

	@isTest
	private static void getDownSaturdayNight_doesntGetDown_OnASchoolNight_WithMatchers()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		IDiscoService mockDisco = new Mocks.DiscoService(mocks);
		Application.Service.setMock(IDiscoService.class, mockDisco);

		//Given
		User u = new User(
			FirstName = 'Buzz',
			LastName = 'Killington',
			LikesToParty__c = false,
			CantWaitForTheWeekend__c = false
		);
		
		//When
		AwesomeService.getDownSaturdayNight(u, KNOWN_SUNDAY);

		//Then
		DiscoService.Event expected = new DiscoService.Event();
		expected.EventTarget = u;
		expected.EventType = 'Uncool';
		expected.Message = 'It\'s hip to be a square';

		((IDiscoService)mocks.verify(mockDisco)).notifyUser(matchesEvent(expected));
	}

	private static DiscoService.Event matchesEvent(DiscoService.Event toMatch)
	{
		return (DiscoService.Event)fflib_Match.matches(new MatchesEvent(toMatch));
	}

	private class MatchesEvent implements fflib_IMatcher
	{
		private DiscoService.Event toMatch;
		public MatchesEvent(DiscoService.Event toMatch)
		{
			this.toMatch = toMatch;
		}

		public Boolean matches(Object obj)
		{
			if (obj != null && obj instanceof DiscoService.Event)
			{
				DiscoService.Event other = (DiscoService.Event)obj;
				return other.EventTarget == toMatch.EventTarget
					&& other.EventType == toMatch.EventType
					&& other.Message == toMatch.Message;
			}

			return true;
		}
	}
}