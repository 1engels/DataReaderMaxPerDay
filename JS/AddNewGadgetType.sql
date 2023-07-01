USE ApplicationModules
--************************************************************************
-- SQL Script to add a new gadget type definition to the ApplicationModules
-- database. 
--************************************************************************
--************************************************************************
-- SCRIPT CONFIGURATION
--************************************************************************
DECLARE @gadgetTypeId UNIQUEIDENTIFIER 
DECLARE @gadgetTypeName NVARCHAR(255) 
DECLARE @description NVARCHAR(MAX) 
DECLARE @imageName NVARCHAR(255) 
DECLARE @gadgetXml XML
DECLARE @gadgetGroupName NVARCHAR(255)
DECLARE @dataReaderAlias UNIQUEIDENTIFIER

--************************************************************************
-- Edit the values below as appropriate for your gadget.
SELECT 
	  -- Unique ID for the gadget type
	  @gadgetTypeId = 'ed887343-c40d-4be1-8c12-c9c4d4be4806'
	  -- Description: this gets shown in the 'Add Gadget' workflow
	, @description = 'Chart maximum values per day'
	  -- Name; name that should appear in the UI for the gadget type
	  --	The name will not be localized.
	, @gadgetTypeName = 'Maximum Per Day'
	  -- Image name: file name of the gadget thumbnail image, if not found a default is shown
	, @imageName = 'GadgetThumbnail.png'
	  -- Group: this is the group for the 'Add Gadget' workflow
	  --	you may only specify an existing name or 'Custom' as the script
	  --    does not create arbitrary groups
	, @gadgetGroupName = NULL
	  -- Data reader alias: it is possible to get data from an existing data reader
	  --	(such as the ones that supply data to factory gadgets)
	  --	to do this use supply the gadget type ID of the other gadget here
	, @dataReaderAlias = NULL
	--, @dataReaderAlias = 'C4491CD2-D10D-426D-B5B4-9FA7D14DC865'

-- GadgetXml: this contains the default XML configuration settings that are
--            present for a newly created gadget instance.
-- Paste in the contents of the GadgetSettings.xml file for the current example.
SET @gadgetXml = '<!-- Example 5: Basic Gadget Settings + Viewing Period Settings + Data Series Settings -->
<SetupItems>
    <SetupItem SetupControlId="78E4698E-DAF8-11DF-8977-B2F3DFD72085">
        <!--Summary Control-->
        <Settings>
            <Setting name="Title" />
            <Setting name="Description" />
        </Settings>
    </SetupItem>
    <SetupItem SetupControlId="5BA40EA6-DAF8-11DF-8852-4EF3DFD72085">
        <!--Data Series Control-->
        <Settings>
            <Setting name="PrimaryCustomizeUnit">False</Setting>
            <Setting name="PrimaryDisplayUnit" />
            <Setting name="PrimaryDataSeries1" />
            <Setting name="SecondaryCustomizeUnit">False</Setting>
            <Setting name="SecondaryDisplayUnit" />
            <Setting name="SecondaryDataSeries" />
            <Setting name="MaximumNumberOfSeries">1</Setting>
        </Settings>
    </SetupItem>
 	<SetupItem SetupControlId="9B785FD2-DAF8-11DF-944E-F6F3DFD72085">
        <!--Viewing Period Control-->
        <Settings>
            <Setting name="ViewingPeriodForumulaOne">this month</Setting>
            <Setting name="ViewingPeriodForumulaTwo" />
            <Setting name="SelectedPeriodId">42</Setting>
            <Setting name="DefaultRefreshSeconds">300</Setting>
	        <Setting name="SelectedAggregationId">1</Setting>            
        </Settings>
    </SetupItem>
	<SetupItem SetupControlId="00000000-0000-0000-0000-000000000000">
		<!-- Hidden Control used for Versioning -->
		<Settings>
			<Setting name="Compatibility">HTML</Setting>
			<Setting name="Comment"></Setting>				
			<Setting name="Version">2</Setting>
		</Settings>
	</SetupItem>
</SetupItems>'	

--************************************************************************
-- BEGIN GADGET TYPE INSERT SCRIPT
-- DO NOT CHANGE ANYTHING BELOW THIS COMMENT BLOCK
--************************************************************************

-- If something goes wrong don't leave any wreckage 
BEGIN TRANSACTION

BEGIN TRY

-- Make sure we have some XML that looks valid
IF (0 = @gadgetXml.exist('/SetupItems/SetupItem')) 
BEGIN
	RAISERROR('GadgetXml value not valid.', 16, 1)
END

-- If gadget type already exists update it with the settings
-- Note that the group doesn't get changed
IF EXISTS (SELECT [GadgetId] FROM [Dashboard].[Gadget] WHERE [GadgetId] = @gadgetTypeId)
BEGIN
	PRINT 'Updating gadget'
	UPDATE [Dashboard].[Gadget]
	SET	
		  [DisplayName] = @gadgetTypeName
		, [GadgetName] = @gadgetTypeName
		, [Description] = @description
		, [ResourceClassName] = @gadgetTypeName
		, [ThumbnailPath] = @imageName
		, [GadgetXml] = @gadgetXml
		, [DataReaderAlias] = @dataReaderAlias
	WHERE
		[GadgetId] = @gadgetTypeId	
END
ELSE
BEGIN
	--************************************************************************
	-- Insert gadget type
	PRINT 'Adding gadget type'
	INSERT INTO [Dashboard].[Gadget] (
		  [GadgetId]
		 ,[DisplayName]
		 ,[Description]
		 ,[GadgetName]
		 ,[GadgetXml]
		 ,[ResourceClassName]
		 ,[ThumbnailImage]
		 ,[ThumbnailPath]
		 ,[DataReaderAlias]
	)
	VALUES (
		  @gadgetTypeId
		, @gadgetTypeName
		, @description
		, @gadgetTypeName
		, @gadgetXml
		, @gadgetTypeName
		, NULL
		, 'GadgetThumbnail.png'
		, @dataReaderAlias
	)
		
	--************************************************************************
	-- Insert gadget group
	DECLARE @gadgetGroupId UNIQUEIDENTIFIER
	SELECT @gadgetGroupId = [GroupId] FROM [Dashboard].[GadgetGroup] WHERE [GroupName] = ISNULL(@gadgetGroupName, 'Custom')
	IF (@gadgetGroupId IS NULL)
	BEGIN 	
		PRINT 'Creating Custom gadget group'
		SET @gadgetGroupId = '0df600b5-f63e-41d3-b140-adb6c3c1bf1e'
		INSERT INTO [Dashboard].[GadgetGroup]
		([GroupId], [GroupName], [ResourceClassName])
		VALUES
		(@gadgetGroupId, 'Custom', 'Custom')
	END

	--************************************************************************
	-- Define gadget group membership
	PRINT 'Adding gadget group membership'
	INSERT INTO [Dashboard].[GadgetGroupMembership]
			   ([GadgetId], [GroupId])
		 VALUES
			   (@gadgetTypeId, @gadgetGroupId)

END
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	PRINT 'Gadget type not added due to errors.'
END CATCH
